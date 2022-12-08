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
--- @field bubble boolean
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
	title.bubble = title_opts.bubble

	return setmetatable(title, self)
end

--- @return string[]
function Title:generate_lines()
	-- TODO: make length dividable by len(self.filler_seq)
	-- Setup filler for the title line
	local filler_amount = (self.len - string.len(self.text) - 2) / 2
	local filler_string = self.filler_seq
	if self.bubble then
		filler_string = ' '
	end
	filler_amount = filler_amount / string.len(filler_string)

	-- Setup filler with only border
	local left_filler = self.filler_seq
	for _ = 1, filler_amount - 1, 1 do
		left_filler = left_filler .. filler_string
	end

	local right_filler = ''
	for _ = 1, filler_amount - 1, 1 do
		right_filler = right_filler .. filler_string
	end
	right_filler = right_filler .. self.filler_seq

	local title_line = left_filler .. ' ' .. self.text .. ' ' .. right_filler

	-- Setup box
	local box_border = ""
	for _ = 1, self.len / string.len(self.filler_seq), 1 do
		box_border = box_border .. self.filler_seq
	end

	local box_line_filler = ""
	if self.bubble then
		box_line_filler = ' '
	else
		box_line_filler = self.filler_seq
	end
	local box_line = ""
	for _ = 1, self.len / string.len(box_line_filler), 1 do
		box_line = box_line .. box_line_filler
	end

	local lines = {}
	-- Draw top box border
	table.insert(lines, box_border)
	-- Draw top part of the box
	for _ = 1, self.lines_amount / 2 - 1, 1 do
		table.insert(lines, box_line)
	end

	-- Draw title line
	table.insert(lines, title_line)

	-- Draw bottom part of the box
	for _ = 1, self.lines_amount / 2 - 1, 1 do
		table.insert(lines, box_line)
	end
	-- Draw bottom box border
	table.insert(lines, box_border)

	return lines
end

M.Title = Title

return M
