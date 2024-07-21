local function RunFile()
	local filename = vim.fn.expand("%:p")
	local Job = require("plenary.job")
	Job:new({
		command = "go run " .. filename,
		on_stdout = function(error, data, self)
			print(data)
		end,
	})

	-- local job = vim.fn.jobstart("go run " .. filename)
end

vim.api.nvim_create_user_command("Runfile", function()
	RunFile()
end, {
	desc = "Run file",
})
