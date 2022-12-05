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
---    -- Preview window settings
---    preview = {
---        highlight = 'Comment', -- Highlight group of the preview
---        border = 'rounded', -- Border of the preview window
---    },
---    -- Default title settings, `require('title-nvim').title({title_opts})`
---    default_title = {
---        text = 'Title', -- Text
---        len = 40, -- Length
---        filler_sequence = '-', -- Filler sequence
---        lines_amount = 3, -- Amount of lines of the title
---    }
---}
---@usage ]]
M.setup = function(user_config)
    user_config = user_config or {}
    config = vim.tbl_deep_extend('keep', user_config, common.default_config)
end

api.nvim_create_user_command('Title', function()
    window.new_title(config.default_title)
end, {})

M.title = window.new_title

return M
