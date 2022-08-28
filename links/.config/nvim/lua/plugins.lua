require "packer".startup(function (use)
  -- # packer.nvim itself.
  use "wbthomason/packer.nvim"

  -- toolbar.
  use "liuchengxu/eleline.vim"
  -- theme.
  use "w0ng/vim-hybrid"
  -- dir tree, bookmarks and more.
  use "scrooloose/nerdtree"
  -- show file change inline.
  use "airblade/vim-gitgutter"
  -- sub-word movements.
  use "bkad/CamelCaseMotion"
  -- Surround.vim is all about "surroundings": parentheses, brackets, quotes,
  -- XML tags, and more. The plugin provides mappings to easily delete,
  -- change and add such surroundings in pairs.
  use "tpope/vim-surround"
  -- git wrapper.
  use "tpope/vim-fugitive"
  -- 🔗 the fancy start screen for Vim.
  use "mhinz/vim-startify"
  -- align something.
  use "vim-scripts/Align"
  -- search and replace through the whole project.
  use "dyng/ctrlsf.vim"
  -- auto completion.
  use { "neoclide/coc.nvim"
      , tag = "v0.0.81"
      }
  -- repeat plugin map.
  use "tpope/vim-repeat"
  -- comment stuffs easily.
  use "tpope/vim-commentary"
  -- auto close pairs.
  use "BurningLutz/vim-autoclose"
  -- block-wise alignment.
  use "BurningLutz/blockalign.nvim"
  -- markdown preview.
  use { "iamcco/markdown-preview.nvim"
      , run   = "cd app && npm install"
      , ft    = { "markdown" }
      , setup = function ()
                  vim.g.mkdp_filetypes = { "markdown" }
                end
      }
  -- markdown generate toc.
  use { "mzlogin/vim-markdown-toc"
      , ft = { "markdown" }
      }
  -- markdown table mode.
  use { "dhruvasagar/vim-table-mode"
      , ft = { "markdown" }
      }
  -- editorconfig.
  use "editorconfig/editorconfig-vim"
  -- db.
  use "tpope/vim-dadbod"
  use "kristijanhusak/vim-dadbod-ui"
  -- treesitter, the syntax parser providing highlighting and textobjects.
  use { "nvim-treesitter/nvim-treesitter"
      , run    = function ()
                   require "nvim-treesitter.install".update { with_sync = true }
                 end
      , config = function ()
                   require "nvim-treesitter.configs".setup
                   { auto_install = true
                   , highlight    = { enable = true
                                    , additional_vim_regex_highlighting = false
                                    }
                   , textobjects  = { select = { enable          = true
                                               , keymaps         = { ["af"] = "@function.outer"
                                                                   , ["if"] = "@function.inner"
                                                                   , ["ac"] = "@class.outer"
                                                                   , ["ic"] = "@class.inner"
                                                                   }
                                               , selection_modes = { ["@function.outer"] = "V"
                                                                   , ["@class.outer"]    = "V"
                                                                   }
                                               , include_surrounding_whitespace = true
                                               }
                                    , swap   = { enable        = true
                                               , swap_next     = { ["<leader>p"] = { "@parameter.inner" }
                                                                 }
                                               , swap_previous = { ["<leader>P"] = { "@parameter.inner" }
                                                             }
                                               }
                                    }
                   , rainbow      = { enable = true }
                   }
                 end
      }
  use "nvim-treesitter/nvim-treesitter-textobjects"
  use "p00f/nvim-ts-rainbow"
end)
