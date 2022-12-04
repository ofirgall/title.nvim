local M = {}

M.FILE_TYPE = "title-nvim"

M.default_config = {
	preview_highlight = 'Comment',
	default_title = {
		text = 'Title',
		len = 40,
		filler_sequence = '-',
		lines_amount = 3,
	}
}

return M
