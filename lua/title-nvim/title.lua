local M = {}

---@type Title[]
local titles = {}


--- @class Title
--- @field text string
--- @field len number
--- @field filler_seq string
--- @field lines_amount number
local Title = {}

function Title:new(title)
	title = title or {}
	-- TODO: configruable start values (reset each title)
	title.text = "Title Example"
	title.len = 60
	title.filler_seq = "-"
	title.lines_amount = 1

	return setmetatable(title, self)
end

function Title:generate()
	local filler_amount = (self.len - string.len(self.text) - 2) / 2
	filler_amount = filler_amount / string.len(self.filler_seq)
	local filler = ""
	for _ = 1, filler_amount, 1 do
		filler = filler .. self.filler_seq
	end

	local output_title = filler .. ' ' .. self.text .. ' ' .. filler
	local wrapped_line = ""
	for _ = 1, self.len, 1 do
		wrapped_line = wrapped_line .. self.filler_seq
	end

	local lines = {}
	for _ = 1, self.lines_amount / 2, 1 do
		table.insert(lines, wrapped_line)
	end
	table.insert(lines, output_title)
	for _ = 1, self.lines_amount / 2, 1 do
		table.insert(lines, wrapped_line)
	end

	return lines

	-- TODO: execute title
	-- local pos = api.nvim_win_get_cursor(0)[1] - 1
	-- api.nvim_buf_set_lines(0, pos, pos, false, lines)
end

return M
