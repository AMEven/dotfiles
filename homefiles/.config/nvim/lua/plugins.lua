return
{ -- statusline.
  { "nvim-lualine/lualine.nvim"
  , opts = {
      options = {
        theme = "OceanicNext"
      , refresh = {
          statusline = 100
        , tabline    = 100
        , winbar     = 100
        }
        -- alpha is the filetype of start screen.
      , disabled_filetypes = { "alpha" }
      }
    , sections = {
        lualine_c = {
          "filename"
        , function ()
            return require "lsp-progress".progress()
          end
        }
      }
    }
  }
, { "linrongbin16/lsp-progress.nvim"
  , version = "*"
  , config = function ()
      require "lsp-progress".setup {}
    end
  }
  -- theme.
, { "HoNamDuong/hybrid.nvim"
  , priority = 1000
  , lazy = false
  , config = function ()
      -- first we customize default palette to reduced contrast version.
      local p = require "hybrid.colors".palette
      p.bright_black = "#425059"
      p.black        = "#232c31"
      p.dull_white   = "#6c7a80"

      -- and then setup.
      require "hybrid".setup {
        overrides = function (hl, c)
          hl.GitGutterAdd    = { link = "diffAdded" }
          hl.GitGutterChange = { link = "diffChanged" }
          hl.GitGutterDelete = { link = "diffRemoved" }
          -- the original colors are hard to see, so I revert them.
          hl.TabLine         = { fg = c.bg, bg = c.fg }
          hl.TabLineFill     = { fg = c.bg, bg = c.fg }
        end
      }
    end
  }
  -- dir tree, bookmarks and more.
, { "nvim-tree/nvim-tree.lua"
  , dependencies = { "nvim-tree/nvim-web-devicons" }
  , opts = { system_open   = { cmd = "wslview" }
           , disable_netrw = true
           , renderer      = { icons = { git_placement = "after" } }
           , actions       = { open_file = { quit_on_open = true } }
           , filters       = { custom = { "^\\.git$" } }
           }
  }
  -- show file change inline.
, "airblade/vim-gitgutter"
  -- sub-word movements.
, "bkad/CamelCaseMotion"
  -- Surround selections, stylishly 😎
, { "kylechui/nvim-surround"
  , version = "*" -- Use for stability; omit to use `main` branch for the latest features
  , opts = { indent_lines = false
           }
  }
  -- git wrapper.
, "tpope/vim-fugitive"
  -- highly customizable start screen.
, { "goolord/alpha-nvim"
  , dependencies = { "nvim-tree/nvim-web-devicons" }
  , config = function ()
               local sessutil  = require "auto-session"
               local fortune   = require "alpha.fortune"
               local dashboard = require "alpha.themes.dashboard"

               local buttsonvals = {}

               table.insert( buttsonvals
                           , { type = "text"
                             , val  = "Sessions"
                             , opts = { hl       = "Title"
                                      , position = "center"
                                      }
                             }
                           )
               for n, sess in ipairs({ unpack(sessutil.get_session_files(), 1, 3) }) do
                 local name = string.match(sess.display_name, ".*/(.*)$")
                 local cmd  = ":lua require 'auto-session'.RestoreSession('"..sess.display_name.."')<CR>"
                 local btn  = dashboard.button(tostring(n), "  "..name, cmd)

                 table.insert(buttsonvals, btn)
               end
               table.insert( buttsonvals
                           , { type = "padding"
                             , val  = 1
                             }
                           )
               table.insert( buttsonvals
                           , { type = "text"
                             , val  = "Action"
                             , opts = { hl       = "Title"
                                      , position = "center"
                                      }
                             }
                           )
               table.insert(buttsonvals, dashboard.button("e", "  New file", ":ene<CR>"))
               table.insert(buttsonvals, dashboard.button("p", "  Open session", ":Telescope session-lens<CR>"))
               table.insert(buttsonvals, dashboard.button("q", "󰿅  Quit", ":qa!<CR>"))

               dashboard.section.buttons.val = buttsonvals

               dashboard.section.footer.val     = fortune()
               dashboard.section.footer.opts.hl = "String"

               require "alpha".setup(dashboard.config)
             end
  }
  -- session management.
, { "rmagatti/auto-session"
  , config = function ()
               local ignored_filetypes = { "gitcommit", "gitrebase", "fugitive", "NvimTree" }

               require "auto-session".setup
               ---@diagnostic disable-next-line: missing-fields
               { auto_session_create_enabled = false
               , auto_restore_enabled        = false
               , auto_session_use_git_branch = false
               -- it's critical to set `cwd_change_handling` to nil to work-around a
               -- "session cleared unexpectedly" issue.
               -- see https://github.com/rmagatti/auto-session/issues/205
               , cwd_change_handling         = nil
               , session_lens                = { theme_conf  = { winblend = 0 }
                                               , borderchars = { prompt  = { "─", "│", " ", "│", "┌", "┐", "┘", "└" }
                                                               , results = { "─", "│", "─", "│", "├", "┤", "┘", "└" }
                                                               }
                                               }
               -- hooks
               , pre_save_cmds               = { function ()
                                                   -- delete buffers that should not be saved into a session.
                                                   for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                                                     local buf_ft = vim.api.nvim_buf_get_option(buf, "filetype")

                                                     if vim.api.nvim_buf_is_valid(buf) and vim.tbl_contains(ignored_filetypes, buf_ft) then
                                                       vim.api.nvim_buf_delete(buf, { force = true })
                                                     end
                                                   end
                                                 end
                                               }
               }
             end
  }
  -- align something.
, "vim-scripts/Align"
  -- search and replace through the whole project.
, "dyng/ctrlsf.vim"
  -- auto completion.
, { "hrsh7th/nvim-cmp"
  , dependencies  = { "hrsh7th/cmp-path"
                    , "hrsh7th/cmp-buffer"
                    , "hrsh7th/cmp-nvim-lsp"
                    , "hrsh7th/cmp-vsnip"
                    , "hrsh7th/vim-vsnip"
                    }
  , config = function ()
               local cmp     = require "cmp"
               local compare = require "cmp.config.compare"
               local map     = cmp.mapping

               cmp.setup
               { preselect = cmp.PreselectMode.None
               , snippet   = { expand = function (args)
                                          vim.fn["vsnip#anonymous"](args.body)
                                        end
                             }
               , sorting   = { comparators = { compare.offset
                                             , compare.exact
                                             , compare.score
                                             , compare.recently_used
                                             , compare.locality
                                             , compare.sort_text
                                             , compare.length
                                             , compare.kind
                                             , compare.order
                                             }
                             }
               , mapping   = map.preset.insert(
                             { ["<C-b>"]      = map.scroll_docs(-4)
                             , ["<C-f>"]      = map.scroll_docs(4)
                             , ["<CR>"]       = map.confirm()
                             , ["<Tab>"]      = map( function(fallback)
                                                       if cmp.visible() then
                                                         cmp.select_next_item({ behavior = cmp.SelectBehavior })
                                                       else
                                                         fallback()
                                                       end
                                                     end
                                                   , { "i" }
                                                   )
                             , ["<S-Tab>"]    = map( function(fallback)
                                                       if cmp.visible() then
                                                         cmp.select_prev_item({ behavior = cmp.SelectBehavior })
                                                       else
                                                         fallback()
                                                       end
                                                     end
                                                   , { "i" }
                                                   )
                             , ["<C-x><C-o>"] = map.complete()
                             }
                             )
               , sources   = { { name = "path" }
                             , { name = "buffer", group_index = 2 }
                             , { name = "nvim_lsp" }
                             , { name = "vsnip" }
                             }
               }
             end
  }
, { "neovim/nvim-lspconfig"
  , config = function ()
               local lspconfig = require "lspconfig"
               lspconfig.util.default_config = vim.tbl_extend( "force"
                                                             , lspconfig.util.default_config
                                                             , require "cmp_nvim_lsp".default_capabilities()
                                                             )

               lspconfig.hls.setup
               { filetypes = { "haskell", "lhaskell", "cabal" }
               , settings  = { haskell = { plugin = { ["ghcide-completions"] = { config = { snippetsOn   = false
                                                                                          , autoExtendOn = false
                                                                                          }
                                                                               }
                                                    }
                                         , maxCompletions     = 100
                                         , formattingProvider = "stylish-haskell"
                                         }
                             }
               }
               lspconfig.pyright.setup
               { settings = { python = { pythonPath = ".venv/bin/python"
                                       , analysis   = { typeCheckingMode      = "off"
                                                      , autoImportCompletions = false
                                                      }
                                       }
                            }
               }
               lspconfig.lua_ls.setup
               { settings = { Lua = { runtime     = { version = "LuaJIT" }
                                    , diagnostics = { globals = { "vim" } }
                                    , workspace   = { library         = vim.api.nvim_get_runtime_file("", true)
                                                    , checkThirdParty = false
                                                    }
                                    , telemetry   = { enable = false }
                                    }
                            }
               }
               lspconfig.tsserver.setup {}
               lspconfig.gopls.setup {}
               lspconfig.jdtls.setup
               { cmd = { "jdt-language-server"
                       , "-configuration"
                       , os.getenv("HOME").."/.cache/jdtls/config"
                       , "-data"
                       , os.getenv("HOME").."/.cache/jdtls/workspace"
                       }
               }
               lspconfig.clangd.setup {}
               lspconfig.rust_analyzer.setup
               { settings = { ["rust-analyzer"] = { diagnostics = { enable = true }
                                                  , cargo = { allFeatures = true }
                                                  }
                            }
               , root_dir = lspconfig.util.root_pattern("Cargo.toml")
               , filetypes = { "rust" }
               }
             end
  }
  -- repeat plugin map.
, "tpope/vim-repeat"
  -- comment stuffs easily.
, "tpope/vim-commentary"
  -- auto close pairs.
, { "windwp/nvim-autopairs"
  , opts = {}
  }
  -- block-wise alignment.
, { "BurningLutz/blockalign.nvim"
  , dependencies = { "Align" }
  }
  -- markdown preview.
, { "iamcco/markdown-preview.nvim"
  , build = "cd app && yarn install"
  , ft    = { "markdown" }
  , init  = function ()
              vim.g.mkdp_filetypes = { "markdown" }
            end
  }
  -- markdown generate toc.
, { "mzlogin/vim-markdown-toc"
  , ft = { "markdown" }
  }
  -- markdown table mode.
, { "dhruvasagar/vim-table-mode"
  , ft = { "markdown" }
  }
  -- db.
, "tpope/vim-dadbod"
, "kristijanhusak/vim-dadbod-ui"
  -- treesitter, the syntax parser providing highlighting and textobjects.
, { "nvim-treesitter/nvim-treesitter"
  , build  = ":TSUpdate"
  , config = function ()
               require "nvim-treesitter.install".compilers = { os.getenv "NVIM_TREESITTER_COMPILER_PATH" }
               require "nvim-treesitter.configs".setup
               ---@diagnostic disable-next-line: missing-fields
               { ensure_installed = { "diff"
                                    , "markdown"
                                    , "markdown_inline"
                                    , "c"
                                    , "lua"
                                    , "query"
                                    , "vim"
                                    , "vimdoc"
                                    }
               , sync_install     = true
               , auto_install     = true
               , highlight        = { enable = true
                                    , additional_vim_regex_highlighting = false
                                    }
               , textobjects      = { select = { enable  = true
                                               , keymaps = { ["af"] = "@function.outer"
                                                           , ["if"] = "@function.inner"
                                                           , ["ac"] = "@class.outer"
                                                           , ["ic"] = "@class.inner"
                                                           }
                                               }
                                    , swap   = { enable = true
                                               }
                                    }
               }
             end
  }
, { "nvim-treesitter/nvim-treesitter-textobjects"
  , dependencies = { "nvim-treesitter" }
  }
  -- lists.
, { "nvim-telescope/telescope.nvim"
  , dependencies = { "nvim-lua/plenary.nvim", "telescope-fzf-native.nvim", "rmagatti/auto-session" }
  , version      = "*"
  , config       = function ()
                     require "telescope".setup
                     { defaults = { scroll_strategy = "limit"
                                  , wrap_results    = true
                                  , path_display    = { "smart" }
                                  , borderchars     = { "─", "│", "─", "│", "┌", "┐", "┘", "└" }
                                  , mappings        = { i = { ["<ESC>"] = "close"
                                                            , ["<C-a>"] = { "<Home>"   , type = "command" }
                                                            , ["<C-e>"] = { "<End>"    , type = "command" }
                                                            , ["<C-d>"] = { "<Del>"    , type = "command" }
                                                            , ["<C-b>"] = { "<Left>"   , type = "command" }
                                                            , ["<C-f>"] = { "<Right>"  , type = "command" }
                                                            , ["<C-u>"] = { "<C-u>"    , type = "command" }
                                                            , ["<A-b>"] = { "<S-Left>" , type = "command" }
                                                            , ["<A-f>"] = { "<S-Right>", type = "command" }
                                                            }
                                                      }
                                  }
                     }

                     require "telescope".load_extension "fzf"
                     require "telescope".load_extension "session-lens"
                   end
  }
, { "nvim-telescope/telescope-fzf-native.nvim"
  , build = "make"
  }
  -- builtin ui replacement.
, { "stevearc/dressing.nvim"
  , config = function ()
               require "dressing".setup
               { input  = { enabled        = true
                          , default_prompt = "> "
                          , prompt_align   = "center"
                          , border         = "single"
                          , win_options    = { winblend     = 0
                                             , winhighlight = "Normal:TelescopePromptNormal"
                                             }
                          , mappings       = { i = { ["<C-a>"] = "<Home>"
                                                   , ["<C-e>"] = "<End>"
                                                   , ["<C-d>"] = "<Del>"
                                                   , ["<C-b>"] = "<Left>"
                                                   , ["<C-f>"] = "<Right>"
                                                   , ["<A-b>"] = "<S-Left>"
                                                   , ["<A-f>"] = "<S-Right>"
                                                   }
                                             }
                          , override       = function (conf)
                                               conf.row = 1

                                               return conf
                                             end
                          }
               , select = { enabled     = true
                          , backend     = { "telescope" }
                          , trim_prompt = false
                          , telescope   = require "telescope.themes".get_cursor { borderchars = { prompt  = { "─", "│", " ", "│", "┌", "┐", " ", " " }
                                                                                                , results = { "─", "│", "─", "│", "├", "┤", "┘", "└" }
                                                                                                }
                                                                                }
                          }
               }
             end
  }
, { "GCBallesteros/NotebookNavigator.nvim"
  , event = "VeryLazy"
  , opts  = { syntax_highlight = true
            }
  }
, { "hkupty/iron.nvim"
  , event  = "VeryLazy"
  , config = function ()
               require "iron.core".setup
               { config = { repl_open_cmd  = "leftabove vsplit"
                          , highlight_last = false
                          }
               }
             end
  }
}
