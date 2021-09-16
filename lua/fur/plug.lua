local plug = {
	specs = {
		"nanozuki/fur.nvim",
		{ "wbthomason/packer.nvim", opt = true },
	},
	packer = {
		ready = false,
	},
}

function plug.use(spec)
	plug.specs[#plug.specs + 1] = spec
end

function plug.boot() -- if packer not install, to installing all missing plugins.
	if plug.packer.ready then
		return
	end
	local install_path = vim.fn.stdpath("data") .. "/site/pack/packer/opt/packer.nvim"
	if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
		vim.fn.system({ "git", "clone", "https://github.com/wbthomason/packer.nvim", install_path })
		vim.cmd("packadd packer.nvim")
		require("packer").load("packer.nvim")
		require("packer").install()
		plug.packer.ready = true
	end
end

-- lazy loading Packer
function plug.load_packer()
	if plug.packer.ready then
		return
	end
	vim.cmd("packadd packer.nvim")
	require("packer").init({
		display = {
			open_fn = require("packer.util").float,
		},
	})
	plug.packer.ready = true
end

function plug.sync()
	plug.load_packer()
	for _, spec in ipairs(plug.specs) do
		require("packer").use(spec)
	end
	require("packer").sync()
end

function plug.compile()
	plug.load_packer()
	require("packer").compile()
end

function plug.unset()
	plug.specs = {
		"nanozuki/fur.nvim",
		{ "wbthomason/packer.nvim", opt = true },
	}
	plug.load_packer()
	require("packer").reset()
end

return plug
