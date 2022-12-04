local M = {}
local api = vim.api
local common = require('title-nvim.common')

--- @class Title
--- @field namespace number
--- @field buf number
--
--- @field text string
--- @field len number
--- @field filler_seq string
--- @field lines_amount number
local Title = {}

--- @return Title
function Title:new(buf, title_opts)
	self.__index = self
	local title = {}
	title.buf = buf
	title.namespace = api.nvim_create_namespace(common.FILE_TYPE)
	title.text = title_opts.text
	title.len = title_opts.len
	title.filler_seq = title_opts.filler_sequence
	title.lines_amount = title_opts.lines_amount

	return setmetatable(title, self)
end

--- @return string[]
function Title:generate_lines()
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
end

M.Title = Title

return M
