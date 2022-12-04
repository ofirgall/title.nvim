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
function Title:new(buf)
	self.__index = self
	local title = {}
	title.buf = buf
	title.namespace = api.nvim_create_namespace(common.FILE_TYPE)
	-- TODO: configruable start values (reset each title)
	title.text = "Title Example"
	title.len = 60
	title.filler_seq = "-"
	title.lines_amount = 1

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
