return {
	"pmizio/typescript-tools.nvim",
	dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
	enabled = true,
	config = function()
		require("typescript-tools").setup({
			on_attach = function()
				vim.keymap.set("n", "<leader>o", "<cmd>TSToolsOrganizeImports")
			end,
		})
	end,
}
