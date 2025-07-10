# todo.nvim
Quick popup TODO list inside a neovim


## 📦 Installation (Lazy.nvim)
```lua
{
  "MorkovnySok/todo-nvim",
  opts = {
    file = "~/.todo.txt",  -- Customize TODO file path
  },
  keys = {
    -- Toggle TODO popup
    {
      "<leader>td",
      function() require("todo").toggle() end,
      desc = "Toggle TODO popup",
    },
    -- Add TODO with current file path
    {
      "<leader>tdp",
      function() require("todo").add_todo_with_path() end,
      desc = "Add TODO with path",
    },
  },
}
