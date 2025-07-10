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
    { "<leader>td", desc = "Toggle TODO popup" },
    { "<leader>tdp", desc = "Add TODO with path" },
  },
}
