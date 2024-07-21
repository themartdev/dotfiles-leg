function Crayons()
	vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
	vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
end

return {
	"rebelot/kanagawa.nvim",
	as = "kanagawa",
	lazy = false,
	config = function()
		vim.cmd("colorscheme kanagawa")
		vim.api.nvim_set_hl(0, "Normal", { bg = "#16161d" })
		vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#16161d" })
		-- Crayons()
		-- vim.api.nvim_set_hl(0, 'TabLine', { bg = 'none' })
		-- vim.api.nvim_set_hl(0, 'TabLineFill', { bg = 'none' })
		-- vim.api.nvim_set_hl(0, 'TabLineSelect', { bg = 'none' })
	end,
}
