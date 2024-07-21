return {
	"lukas-reineke/indent-blankline.nvim",
	-- Enable `lukas-reineke/indent-blankline.nvim`
	-- See `:help ibl`
	main = "ibl",
	opts = {},
	enabled = false,
	config = function()
		require("ibl").setup({
			indent = {
				char = "│",
				tab_char = "│",
			},
		})
	end,
}
