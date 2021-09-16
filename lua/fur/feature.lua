local log = require("fur.log")

local feature = {
	name = nil,
	source = nil,
	children = {},

	setup = function() end,
	plugins = {},
	mappings = {},
}

local all_features = {}
local feature_names = {}

function feature.unset()
	feature_names = {}
end

function feature:new(name, obj)
	if type(name) ~= "string" or name == "" then
		error("feature:new need a name")
	end
	if feature_names[name] ~= nil then
		error("feature's name must be unique")
	end

	obj = obj or {}
	obj.name = name
	all_features[name] = obj
	feature_names[name] = true

	setmetatable(obj, self)
	self.__index = self
	return obj
end

local function set_map(mode, lhs, rhs, opts)
	log.debug("set_map(", mode, lhs, rhs, opts, ")")
	local options = { noremap = true }
	if opts then
		options = vim.tbl_extend("force", options, opts)
	end
	vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

function feature:latest()
	return all_features[self.name] -- reload leatest features after source file
end

function feature:reg_plugins()
	for _, child in ipairs(self.children) do
		child:reg_plugins()
	end
	local lf = self:latest()
	for _, plugin in ipairs(lf.plugins) do
		require("fur.plug").use(plugin)
	end
end

function feature:do_setup()
	for _, child in ipairs(self.children) do
		child:reg_plugins()
	end
	local lf = self:latest()
	lf.setup()
end

function feature:do_mapping()
	for _, child in ipairs(self.children) do
		child:reg_plugins()
	end
	local lf = self:latest()
	lf.setup()
	for _, mapping in ipairs(lf.mappings) do
		local mode, lhs, rhs, opts = mapping[1], mapping[2], mapping[3], mapping[4]
		set_map(mode, lhs, rhs, opts)
	end
end

function feature:reload()
	for _, child in ipairs(self.children) do
		child:reload()
	end

	-- self.setup can't revert
	-- self.plugins needn't revert, will be reset by "lib.plug"
	self.setup = function() end
	for _, mapping in ipairs(self.mappings) do
		local mode, lhs = mapping[1], mapping[2]
		log.debug("unset_key(", mode, lhs, ")")
		vim.api.nvim_del_keymap(mode, lhs)
	end

	if self.source then
		log.debug("source ", self.source)
		vim.cmd("runtime! " .. self.source)
	end
end

return feature
