local M = {}

local todo_file = vim.fn.expand("~/.todo.txt")

local function toggle_item()
	local line = vim.api.nvim_get_current_line()
	local new_line

	-- Handle [ ] -> [x]
	if line:match("%- %[ %]") then
		new_line = line:gsub("%[ %]", "[x]")
	-- Handle [x] -> [ ]
	elseif line:match("%- %[x%]") then
		new_line = line:gsub("%[x%]", "[ ]")
	-- Handle no checkbox case
	elseif line:match("%- ") then
		new_line = line:gsub("%- ", "- [ ] ")
	-- Handle completely empty line
	else
		new_line = "- [ ] " .. line
	end

	vim.api.nvim_set_current_line(new_line)
	vim.cmd("w")
end

-- Add a new empty TODO item below current line
local function add_new_item()
	local lnum = vim.api.nvim_win_get_cursor(0)[1]
	vim.api.nvim_buf_set_lines(0, lnum, lnum, false, { "- [ ] " })
	vim.api.nvim_win_set_cursor(0, { lnum + 1, 5 }) -- Move cursor inside brackets
	vim.cmd("w") -- Auto-save
end

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

	-- Keymaps specific to the TODO buffer
	local opts = { silent = true, buffer = buf }
	vim.keymap.set("n", " ", toggle_item, opts) -- Space to toggle
	vim.keymap.set("n", "<CR>", add_new_item, opts) -- Enter to add new item
	vim.keymap.set("n", "q", M.close, opts)
	vim.keymap.set("n", "<Esc>", M.close, opts)

	-- Auto-save when leaving the buffer
	vim.api.nvim_create_autocmd("BufLeave", {
		buffer = buf,
		callback = function()
			vim.cmd("w")
		end,
	})
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
