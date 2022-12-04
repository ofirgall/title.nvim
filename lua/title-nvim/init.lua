---@mod title.nvim Introduction
---@tag title-nvim
---@brief [[
---Title generator
---@brief ]]
---@divider -
local M = {}

local api = vim.api
local window = require("title-nvim.window")
local common = require("title-nvim.common")

local config = common.default_config

---@param user_config table user config
---@usage [[
-----Leave empty for default values
---require('title-nvim').setup {
---}
---
----- Or setup with custom parameters
---require('title-nvim').setup {
--- TODO: [doc]
---}
---@usage ]]
M.setup = function(user_config)
	user_config = user_config or {}
	config = vim.tbl_deep_extend('keep', user_config, common.default_config)
end

api.nvim_create_user_command('Title', function()
	window.new_title(config.default_title)
end, {})


return M
