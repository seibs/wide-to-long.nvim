# wide-to-long.nvim

Refactor function definitions and calls from wide-to-long and long-to-wide.


## Installation

### vim-plug

```vim
" Vimscript
Plug "nvim-treesitter/nvim-treesitter"
Plug "seibs/wide-to-long.nvim"
```

## Configuration

In your `init.lua`:

```lua
  local wtl = require('wide-to-long')
  wtl.setup{
    attach = function(bufnr, lang)
      vim.keymap.set('n', '<leader>tl', wtl.wide_to_long, { noremap=true, silent=true })
      vim.keymap.set('n', '<leader>tw', wtl.long_to_wide, { noremap=true, silent=true })
    end
  }
```
