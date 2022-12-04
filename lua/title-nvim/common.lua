local M = {}

M.FILE_TYPE = "title-nvim"

M.default_config = {
	preview = {
		highlight = 'Comment',
		border = 'rounded',
	},
	default_title = {
		text = 'Title',
		len = 40,
		filler_sequence = '-',
		lines_amount = 3,
	}
}

return M
