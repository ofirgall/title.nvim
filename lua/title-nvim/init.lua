local M = {}

local api = vim.api
local window = require("title-nvim.window")

api.nvim_create_user_command("TitleBeta", function()
	window.pop()
end, {})

M.setup = function(table)
	local _ = table
	window.create_autocmds()
end

return M
