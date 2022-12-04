local M = {}
local common = require('title-nvim.common')
local Title = require('title-nvim.title').Title
local api = vim.api


-- TODO: Features
--		* Reedit last title
--		* Edit an existing title


-- TODO: configureable
local preview_higlight = "Comment"

local MIN_WIDTH = 30
local BASE_HEIGHT = 5

local function always_odd(input, delta)
	if (input + delta) % 2 == 0 then
		return input + delta + delta
	end
	return input + delta
end

local function same(input, delta)
	return input + delta
end

local line_to_option = {
	{ title = "Title", key = "text" },
	{ title = "Amount of lines", key = "lines_amount", change_amount = always_odd },
	{ title = "Title length", key = "len", change_amount = same },
	{ title = "Filler sequence", key = "filler_seq" },
}

---@type Title[]
local titles = {}

local function get_buf_window(buf)
	for _, win in ipairs(api.nvim_list_wins()) do
		if api.nvim_win_get_buf(win) == buf then
			return win
		end
	end

	return nil
end

---@param title Title
local function render_window(title)
	local win = get_buf_window(title.buf)
	if win ~= nil then
		api.nvim_win_close(win, true)
	end

	local win_width = math.max(MIN_WIDTH, title.len - 1)

	win = api.nvim_open_win(title.buf, true, {
		relative = "cursor",
		width = win_width,
		col = 0,
		row = 0,
		style = "minimal",
		height = BASE_HEIGHT + title.lines_amount,
		border = "rounded", -- TODO: [config]
	})

	-- TODO: design with higlights
	local curr_line = 0
	api.nvim_buf_clear_namespace(title.buf, title.namespace, 0, -1)

	-- Get ready lines with highlight
	local lines = title:generate_lines()
	local preview_lines = {}
	for index, line in ipairs(lines) do
		if index ~= 1 then -- First line is the text line
			table.insert(preview_lines, { { line, preview_higlight } })
		end
	end

	-- Create spacer and add the preview
	local spacer = ""
	for _ = 1, win_width, 1 do
		spacer = spacer .. "─"
	end
	table.insert(preview_lines, { { spacer, "FloatBorder" } }) -- spacer

	-- Draw title + border
	-- First line of the title is a real empty line with `virt_text` next to it
	-- All the other lines are lines[2:] and the border
	api.nvim_buf_set_extmark(title.buf, title.namespace, curr_line, 0, {
		virt_text_pos = "overlay",
		virt_text = { { lines[1], preview_higlight } },
		virt_lines = preview_lines,
	})
	curr_line = 1 -- Only 1 real text line and virtual text next to it

	-- Draw options
	local options_lines = {}
	for _, option in ipairs(line_to_option) do
		table.insert(options_lines, option.title .. ': ' .. title[option.key])
	end
	api.nvim_buf_set_lines(title.buf, curr_line, -1, false, options_lines)

end

local map = function(buf, mode, lhs, rhs)
	vim.keymap.set(mode, lhs, rhs, { buffer = buf })
end

local type_to_process_fn = {
	["number"] = function(input)
		return tonumber(input, 10)
	end,
	["string"] = function(input)
		return input
	end
}

local function get_option_on_cursor()
	local target_line = api.nvim_win_get_cursor(0)[1]

	local target_option = nil
	-- First line is the preview == edit title
	if target_line == 1 then
		target_option = 1
	else
		target_option = target_line - 1
	end

	return line_to_option[target_option]
end

local function get_current_title()
	return titles[api.nvim_get_current_buf()]
end

local function change_option()
	local title = get_current_title()
	local option = get_option_on_cursor()

	vim.ui.input({
		prompt = option.title .. ': ',
		default = tostring(title[option.key])
	}, function(input)
		if input == "" or input == nil then
			return
		end

		local process_fn = type_to_process_fn[type(title[option.key])]
		if process_fn == nil then
			return
		end

		local result = process_fn(input)
		if result == nil then
			return
		end

		title[option.key] = result
		vim.cmd("stopinsert")
		render_window(title)
	end)
end

local function change_option_amount(delta)
	local option = get_option_on_cursor()
	if option.change_amount == nil then
		return
	end

	local title = get_current_title()
	title[option.key] = option.change_amount(title[option.key], delta)

	render_window(title)
end

local function increase_option()
	change_option_amount(1)
end

local function decrease_option()
	change_option_amount(-1)
end

local function set_mappings(buf)
	map(buf, 'n', 'q', ':q<cr>')
	map(buf, 'n', '<Esc>', ':q<cr>')

	-- change option binds (insert)
	map(buf, 'n', 'i', change_option)
	map(buf, 'n', 'I', change_option)
	map(buf, 'n', 'a', change_option)
	map(buf, 'n', 'A', change_option)
	map(buf, 'n', 'o', change_option)
	map(buf, 'n', 'O', change_option)

	-- Add/decrease option
	map(buf, 'n', 'l', increase_option)
	map(buf, 'n', 'h', decrease_option)
	map(buf, 'n', '<C-a>', increase_option)
	map(buf, 'n', '<C-x>', decrease_option)
end

M.pop = function()
	local buf = api.nvim_create_buf(false, true)
	api.nvim_buf_set_option(buf, "filetype", common.FILE_TYPE)

	local title = Title:new(buf)
	titles[buf] = title

	set_mappings(buf)
	-- TODO: configruable, choose_title
	-- choose_title()
	render_window(titles[buf])
end

return M
