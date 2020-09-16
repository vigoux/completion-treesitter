[![asciicast](https://asciinema.org/a/318046.svg)](https://asciinema.org/a/318046)

[![Gitter](https://badges.gitter.im/completion-nvim/community.svg)](https://gitter.im/completion-nvim/community?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)
# completion-treesitter
Treesitter source and more for [completion-nvim](https://github.com/haorenW1025/completion-nvim).

This is a basic completion source based on the treesitter api of neovim.

**Since v0.1 this only contains a completion source. All other features are being migrated to nvim-treesitter**

# Quickstart

This plugin requires the following plugins:

- [completion-nvim](https://github.com/nvim-lua/completion-nvim)
- [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)

Install them like this (vim-plugged or your favorite package manager):
```vim
Plug 'nvim-lua/completion-nvim'
Plug 'nvim-treesitter/nvim-treesitter'
Plug 'nvim-treesitter/completion-treesitter'
```

## Completion
Configure `completion-nvim` as you desire, you can use the `ts` source for `lua`, `python` and `c` filetypes, for example :
```vim
" Configure the completion chains
let g:completion_chain_complete_list = {
			\'default' : {
			\	'default' : [
			\		{'complete_items' : ['lsp', 'snippet']},
			\		{'mode' : 'file'}
			\	],
			\	'comment' : [],
			\	'string' : []
			\	},
			\'vim' : [
			\	{'complete_items': ['snippet']},
			\	{'mode' : 'cmd'}
			\	],
			\'c' : [
			\	{'complete_items': ['ts']}
			\	],
			\'python' : [
			\	{'complete_items': ['ts']}
			\	],
			\'lua' : [
			\	{'complete_items': ['ts']}
			\	],
			\}

" Use completion-nvim in every buffer
autocmd BufEnter * lua require'completion'.on_attach()
```

Open a buffer of a supported filetype and enjoy !

# Using parsers

## From nvim-treesitter

To install a parser run the following command in nvim for the supported language of your choice :
```vim
:TSInstall lua
```

## From source

To use a parser for one of the supported languages clone the parser sources (the python parser for example) :
```sh
git clone https://github.com/tree-sitter/tree-sitter-python.git
```

Then compile it :
```sh
gcc -o parser.so -shared src/parser.c src/scanner.cc -I./src -lstdc++
```

An move it to neovim config files :

```sh
mv parser.so ~/.config/nvim/parser/{lang}.so
```

Where `{lang}` is the filetype corresponding to the parser's language (`python` in above example).

# Examples usages

Some examples usages of the plugin, not only for completion.
All of these functionnalities are available for all supported filetypes.

# Goals
The aim of the plugin is mainly to fiddle a bit with treesitter, and a nice way is completion, but there is many things we can do with it.

There is still some goals for the plugin:
  - As hackable as possible
  - As fast as possible
