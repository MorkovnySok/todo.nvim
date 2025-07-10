local M = {}

local todo_file = vim.fn.expand("~/.todo.txt")

-- Open TODO popup and prepend a new entry with the current file:line
function M.add_todo_with_path()
	local file_path = vim.fn.expand("%:~") -- Relative to $HOME (e.g., ~/projects/foo.lua)
	local line_num = vim.fn.line(".") -- Current line number
	local todo_prefix = string.format("- [ ] %s:%d ", file_path, line_num)

	-- Open the TODO popup
	M.toggle()

	-- Move cursor to end of file and insert the prefilled TODO
	local buf = vim.fn.bufnr(todo_file)
	vim.api.nvim_buf_set_lines(buf, -1, -1, false, { todo_prefix })
	vim.api.nvim_win_set_cursor(0, { vim.api.nvim_buf_line_count(buf), #todo_prefix })
end

-- Toggle the TODO popup (same as before)
function M.toggle()
	local buf = vim.fn.bufadd(todo_file)
	vim.fn.bufload(buf)

	local width = math.floor(vim.o.columns * 0.6)
	local height = math.floor(vim.o.lines * 0.6)

	vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		col = (vim.o.columns - width) / 2,
		row = (vim.o.lines - height) / 2,
		style = "minimal",
		border = "rounded",
	})

	-- Keymaps
	vim.api.nvim_buf_set_keymap(buf, "n", "q", "<cmd>lua require('todo').close()<CR>", { silent = true })
	vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", "<cmd>lua require('todo').close()<CR>", { silent = true })
	vim.api.nvim_buf_set_keymap(buf, "n", "<CR>", "<cmd>lua require('todo').jump_to_file()<CR>", { silent = true })
end

function M.jump_to_file()
	local line = vim.api.nvim_get_current_line()
	local file, line_num = line:match("(~/.*):(%d+)") -- Matches ~/path:123
	if file and line_num then
		M.close()
		vim.cmd("e " .. vim.fn.expand(file))
		vim.api.nvim_win_set_cursor(0, { tonumber(line_num), 0 })
	end
end

function M.close()
	vim.api.nvim_win_close(0, true)
end

-- Setup function (optional)
function M.setup(opts)
	if opts and opts.file then
		todo_file = opts.file
	end
end

return M
