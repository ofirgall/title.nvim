local M = {}
local api = vim.api

local FT = "title-nvim"
local ns = nil


-- TODO: Features
--		* Reedit last title
--		* Edit an existing title


-- TODO: configureable
local preview_higlight = "Comment"

local MIN_WIDTH = 30
local BASE_HEIGHT = 5

local PREVIEW_LINE = 1
local AMOUNT_OF_LINES_LINE = 2



local insert_lines_to_input_callback = {
	[PREVIEW_LINE] = function(input)

	end
}

local function gen_preview(title)
	local lines = gen_title_lines()
	local preview = ""
	for i, line in ipairs(lines) do
		if i == #lines - 1 then
			preview = line
		else
			preview = line .. '\n'
		end
	end

	return preview
end

local function get_buf_window(buf)
	for _, win in ipairs(api.nvim_list_wins()) do
		if api.nvim_win_get_buf(win) == buf then
			return win
		end
	end

	return nil
end

local function render_window(buf)
	local win = get_buf_window(buf)
	if win ~= nil then
		api.nvim_win_close(win, true)
	end

	local win_width = math.max(MIN_WIDTH, title_len - 1)

	win = api.nvim_open_win(buf, true, {
		relative = "cursor",
		width = win_width,
		col = 0,
		row = 0,
		style = "minimal",
		height = BASE_HEIGHT + title_lines_amount,
		border = "rounded", -- TODO: [config]
	})

	local preview = gen_preview()

	local spacer = ""
	for _ = 1, win_width, 1 do
		spacer = spacer .. "─"
	end

	-- TODO: design with higlights
	local curr_line = 0
	api.nvim_buf_clear_namespace(buf, ns, 0, -1)

	api.nvim_buf_set_extmark(buf, ns, curr_line, 0, {
		virt_text_pos = "overlay",
		virt_text = { { preview, preview_higlight } }, -- Preview
		virt_lines = {
			{ { spacer, "FloatBorder" } }, -- Spacer
		},
	})
	curr_line = curr_line + title_lines_amount + 1

	api.nvim_buf_set_lines(buf, 2, -1, false, {
		"Amount of lines: " .. title_lines_amount,
	})

end

-- TODO: ui.input below/above our window
local function choose_title(buf)
	vim.ui.input({
		prompt = 'Title: ',
		default = title
	}, function(input)
		if input == "" or input == nil then
			return
		end
		title = input
		vim.cmd("stopinsert")
		render_window(buf)
	end)
	if title == "" then
		api.nvim_feedkeys('i', 'n', false)
	end
end

local map = function(buf, mode, lhs, rhs)
	vim.keymap.set(mode, lhs, rhs, { buffer = buf })
end

local function set_mappings(buf)
	map(buf, 'n', 'q', ':q<cr>')
	map(buf, 'n', '<Esc>', ':q<cr>')
end

M.pop = function()
	-- TODO: avoid double creation
	local target_buf = api.nvim_get_current_buf()
	if api.nvim_buf_get_option(target_buf, "filetype") == FT then
		api.nvim_buf_delete(0, {})
	else
		ns = api.nvim_create_namespace(FT)

		local buf = api.nvim_create_buf(false, true)
		api.nvim_buf_set_option(buf, "filetype", FT)

		set_mappings(buf)
		-- TODO: configruable, choose_title
		-- choose_title()
		render_window(buf)
	end
end

local function process_insert_enter(buf)
	local target_pos = api.nvim_win_get_cursor(0)
	local target_line = target_pos[1]
	vim.pretty_print(target_line)
	vim.pretty_print(target_pos)
end

M.create_autocmds = function()
	local auto_group = api.nvim_create_augroup('title-nvim', {})

	api.nvim_create_autocmd('InsertEnter', {
		group = auto_group,
		pattern = "*",
		callback = function(events)
			if api.nvim_buf_get_option(events.buf, 'filetype') == FT then
				process_insert_enter(events.buf)
			end
		end
	})
end

return M
