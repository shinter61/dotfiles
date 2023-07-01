local fn = vim.fn

-- Automatically install packer
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
  PACKER_BOOTSTRAP = fn.system({
    "git",
    "clone",
    "--depth",
    "1",
    "https://github.com/wbthomason/packer.nvim",
    install_path,
  })
end

-- for lazy loading
vim.cmd([[packadd packer.nvim]])

-- Autocommand that reloads neovim whenever you save the plugins.lua file
vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]])

-- Performance
pcall(require, "impatient")

-- plugins
return require("packer").startup(function(use)
  use 'wbthomason/packer.nvim' -- this is essential.

  -- Performance
  use({ "lewis6991/impatient.nvim" })

  -- Colorschemes
  use({
    "folke/tokyonight.nvim",
    requires = {
      "xiyaowong/nvim-transparent",
    },
    config = function()
      require("tokyonight").setup({
        -- your configuration comes here
        -- or leave it empty to use the default settings
        style = "night", -- The theme comes in three styles, `storm`, a darker variant `night` and `day`
        transparent = false, -- Enable this to disable setting the background color
        terminal_colors = true, -- Configure the colors used when opening a `:terminal` in Neovim
        styles = {
          -- Style to be applied to different syntax groups
          -- Value is any valid attr-list value `:help attr-list`
          comments = "italic",
          keywords = "italic",
          functions = "NONE",
          variables = "NONE",
          -- Background styles. Can be "dark", "transparent" or "normal"
          sidebars = "dark", -- style for sidebars, see below
          floats = "dark", -- style for floating windows
        },
        sidebars = { "qf", "help", "Fern", "Telescope" }, -- Set a darker background on sidebar-like windows. For example: `["qf", "vista_kind", "terminal", "packer"]`
        day_brightness = 0.3, -- Adjusts the brightness of the colors of the **Day** style. Number between 0 and 1, from dull to vibrant colors
        hide_inactive_statusline = false, -- Enabling this option, will hide inactive statuslines and replace them with a thin border instead. Should work with the standard **StatusLine** and **LuaLine**.
        dim_inactive = false, -- dims inactive windows
        lualine_bold = true, -- When `true`, section headers in the lualine theme will be bold
      })

      vim.cmd([[colorscheme tokyonight]])
      vim.g.tokyonight_style = "night"
      -- vim.g.tokyonight_transparent = vim.g.transparent_enabled
    end,
  })
  -----------------------------------------------------
  -- filer
  -----------------------------------------------------
  use({
    "lambdalisue/fern.vim",
    config = function()
      vim.api.nvim_set_keymap(
        "n",
        "ss",
        ":Fern . -drawer -width=50 -reveal=%<CR><CR>",
        { noremap = true, silent = true }
      )
      vim.g.fern_disable_startup_warnings = 1
      vim.api.nvim_exec(
        [[
          let g:fern#default_hidden=1
          let g:fern#renderer='nerdfont'
        ]],
        false
      )
    end,
  })
  use({
    "lambdalisue/fern-renderer-nerdfont.vim",
    requires = { "lambdalisue/nerdfont.vim" },
  })
  use({ "lambdalisue/glyph-palette.vim" })
  use({
    "famiu/bufdelete.nvim",
    event = "VimEnter",
    config = function()
      vim.keymap.set("n", "<C-x>", "<Cmd>lua require('bufdelete').bufwipeout(0, true)<CR>",
        { noremap = true, silent = true })
    end,
  })

  -----------------------------------------------------
  -- tabline
  -----------------------------------------------------

  use 'nvim-tree/nvim-web-devicons'
  use({
    "romgrk/barbar.nvim",
    requires = { "kyazdani42/nvim-web-devicons" },
    config = function()
      vim.api.nvim_set_keymap("n", "<C-n>", ":BufferNext<CR>", { noremap = true, silent = true })
      vim.api.nvim_set_keymap("n", "<C-p>", ":BufferPrev<CR>", { noremap = true, silent = true })
    end,
  })

  -----------------------------------------------------
  -- statusline
  -----------------------------------------------------
  use {
    'nvim-lualine/lualine.nvim',
    requires = { 'kyazdani42/nvim-web-devicons', opt = true },
    config = function ()
      local lualine = require("lualine")
      if lualine then
        lualine.setup({
          options = {
            icons_enabled = true,
            theme = "tokyonight",
            component_separators = { left = " ", right = " " },
            section_separators = { left = " ", right = " " },
            always_divide_middle = true
          },
          sections = {
            lualine_a = { "mode" },
            lualine_b = {
              "branch",
              "diff",
            },
            lualine_c = { "require'lsp-status'.status()", "filename" },
            lualine_x = { "encoding", "fileformat", "filetype" },
            lualine_y = { "progress" },
            lualine_z = { "location" },
          },
          extensions = { "fern" }
        })
      end
    end
  }

  -----------------------------------------------------
  -- LSP
  -----------------------------------------------------
  use 'neovim/nvim-lspconfig'
  use 'williamboman/mason.nvim'
  use 'williamboman/mason-lspconfig.nvim'
  use "hrsh7th/nvim-cmp"
  use "hrsh7th/cmp-nvim-lsp"
  use "hrsh7th/vim-vsnip"
  use "hrsh7th/cmp-path"
  use "hrsh7th/cmp-buffer"
  use "hrsh7th/cmp-cmdline"
  use "jose-elias-alvarez/null-ls.nvim"

  -----------------------------------------------------
  -- LSP Server management
  -----------------------------------------------------

  local lspconfig = require('lspconfig')
  local null_ls = require('null-ls')
  require('mason').setup()
  require('mason-lspconfig').setup_handlers({
    function(server)
      local opt = {
        -- -- Function executed when the LSP server startup
        -- on_attach = function(client, bufnr)
        --   local opts = { noremap=true, silent=true }
        --   vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
        --   vim.cmd 'autocmd BufWritePre * lua vim.lsp.buf.formatting_sync(nil, 1000)'
        -- end,
        capabilities = require('cmp_nvim_lsp').default_capabilities(
          vim.lsp.protocol.make_client_capabilities()
        )
      }
      lspconfig[server].setup(opt)
    end,
    ['tsserver'] = function()
      lspconfig.tsserver.setup({
        settings = {
          completions = {
            completeFunctionCalls = true
          }
        }
      })
    end,
    -- ['solargraph'] = function()
    --   lspconfig.solargraph.setup({})
    -- end,
  })

  null_ls.setup({
    sources = {
      null_ls.builtins.formatting.prettier.with({
        condition = function(utils)
          return utils.root_has_file({
            ".prettierrc",
            ".prettierrc.js",
            ".prettierrc.json",
            ".prettierrc.ts",
          })
        end
      }),
    },
    on_attach = function(client, bufnr)
      if client.supports_method("textDocument/formatting") then
        vim.api.nvim_create_autocmd("BufWritePre", {
          buffer = bufnr,
          callback = function()
            vim.lsp.buf.format({ bufnr = bufnr })
          end
        })
      end
    end
  })


  -- lspconfig.solargraph.setup({
  --   on_attach = function(client, bufnr)
  --     -- formatting
  --     if client.server_capabilities.documentFormattingProvider then
  --       vim.api.nvim_create_autocmd("BufWritePre", {
  --         group = vim.api.nvim_create_augroup("Format", { clear = true }),
  --         buffer = bufnr,
  --         callback = function()
  --           vim.lsp.buf.format({ bufnr = bufnr })
  --         end,
  --         desc = "[lsp] format on save",
  --       })
  --     end
  --   end
  -- })

  -----------------------------------------------------
  -- LSP keyboard shortcut
  -----------------------------------------------------
  vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>')
  vim.keymap.set('n', 'gf', '<cmd>lua vim.lsp.buf.formatting()<CR>')
  vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>')
  vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>')
  vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>')
  vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>')
  vim.keymap.set('n', 'gt', '<cmd>lua vim.lsp.buf.type_definition()<CR>')
  vim.keymap.set('n', 'gn', '<cmd>lua vim.lsp.buf.rename()<CR>')
  vim.keymap.set('n', 'ga', '<cmd>lua vim.lsp.buf.code_action()<CR>')
  vim.keymap.set('n', 'ge', '<cmd>lua vim.diagnostic.open_float()<CR>')
  vim.keymap.set('n', 'g]', '<cmd>lua vim.diagnostic.goto_next()<CR>')
  vim.keymap.set('n', 'g[', '<cmd>lua vim.diagnostic.goto_prev()<CR>')

  -----------------------------------------------------
  -- LSP UI
  -----------------------------------------------------

  use { 
    "j-hui/fidget.nvim",
    event = "VimEnter",
    config = function ()
      require("fidget").setup({})
    end
  }

  use {
    "folke/trouble.nvim",
    requires = "nvim-tree/nvim-web-devicons",
    config = function()
      require("trouble").setup {
        position = "bottom", -- position of the list can be: bottom, top, left, right
        height = 10, -- height of the trouble list when position is top or bottom
        width = 50, -- width of the list when position is left or right
        icons = false, -- use devicons for filenames
        mode = "workspace_diagnostics", -- "workspace_diagnostics", "document_diagnostics", "quickfix", "lsp_references", "loclist"
        fold_open = "", -- icon used for open folds
        fold_closed = "", -- icon used for closed folds
        group = true, -- group results by file
        padding = true, -- add an extra new line on top of the list
        action_keys = { -- key mappings for actions in the trouble list
          -- map to {} to remove a mapping, for example:
          -- close = {},
          close = "q", -- close the list
          cancel = "<esc>", -- cancel the preview and get back to your last window / buffer / cursor
          refresh = "r", -- manually refresh
          jump = { "<cr>", "<tab>" }, -- jump to the diagnostic or open / close folds
          open_split = { "<c-x>" }, -- open buffer in new split
          open_vsplit = { "<c-v>" }, -- open buffer in new vsplit
          open_tab = { "<c-t>" }, -- open buffer in new tab
          jump_close = { "o" }, -- jump to the diagnostic and close the list
          toggle_mode = "m", -- toggle between "workspace" and "document" diagnostics mode
          toggle_preview = "P", -- toggle auto_preview
          hover = "K", -- opens a small popup with the full multiline message
          preview = "p", -- preview the diagnostic location
          close_folds = { "zM", "zm" }, -- close all folds
          open_folds = { "zR", "zr" }, -- open all folds
          toggle_fold = { "zA", "za" }, -- toggle fold of current file
          previous = "k", -- preview item
          next = "j", -- next item
        },
        indent_lines = true, -- add an indent guide below the fold icons
        auto_open = false, -- automatically open the list when you have diagnostics
        auto_close = false, -- automatically close the list when you have no diagnostics
        auto_preview = true, -- automatically preview the location of the diagnostic. <esc> to close preview and go back to last window
        auto_fold = false, -- automatically fold a file trouble list at creation
        auto_jump = { "lsp_definitions" }, -- for the given modes, automatically jump if there is only a single result
        signs = {
          -- icons / text used for a diagnostic
          error = "",
          warning = "",
          hint = "",
          information = "",
          other = "﫠",
        },
        use_diagnostic_signs = true, -- enabling this will use the signs defined in your lsp client
      }
      vim.api.nvim_set_keymap("n", "<Space>xx", ":TroubleToggle<CR>", { silent = true, noremap = true })
    end
  }

  -----------------------------------------------------
  -- LSP Auto Completion
  -----------------------------------------------------
-- Set up nvim-cmp.
  local cmp = require'cmp'

  cmp.setup({
    snippet = {
      -- REQUIRED - you must specify a snippet engine
      expand = function(args)
        vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
        -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
        -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
        -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
      end,
    },
    window = {
      -- completion = cmp.config.window.bordered(),
      -- documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert({
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    }),
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'vsnip' }, -- For vsnip users.
      -- { name = 'luasnip' }, -- For luasnip users.
      -- { name = 'ultisnips' }, -- For ultisnips users.
      -- { name = 'snippy' }, -- For snippy users.
    }, {
      { name = 'buffer' },
    })
  })

  -- Set configuration for specific filetype.
  cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources({
      { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
    }, {
      { name = 'buffer' },
    })
  })

  -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline({ '/', '?' }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = 'buffer' }
    }
  })

  -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
      { name = 'path' }
    }, {
      { name = 'cmdline' }
    })
  })
  -----------------------------------------------------
  -- Auto Completion
  -----------------------------------------------------
  use {
    "windwp/nvim-autopairs",
    config = function() require("nvim-autopairs").setup {} end
  }

  -----------------------------------------------------
  -- Snippet
  -----------------------------------------------------
  use({
    "L3MON4D3/LuaSnip",
    -- follow latest release.
    tag = "v<CurrentMajor>.*",
    -- install jsregexp (optional!:).
    run = "make install_jsregexp"
  })


  -----------------------------------------------------
  -- Comments
  -----------------------------------------------------
  use {
    "folke/todo-comments.nvim",
    requires = "nvim-lua/plenary.nvim",
    config = function()
      require("todo-comments").setup {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
      }
    end
  }
  use "tpope/vim-commentary"


  -----------------------------------------------------
  -- Fuzzy Finder
  -----------------------------------------------------
  use {
    'nvim-telescope/telescope.nvim', tag = '0.1.1',
    -- or                            , branch = '0.1.x',
    requires = { { 'nvim-lua/plenary.nvim' } },
    event = { "VimEnter" },
    config = function()
      require('telescope').setup {
        defaults = {
          vimgrep_arguments = {
            "rg",
            "-i",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
          }
        },
        extensions = {
          frecency = {
            ignore_patterns = { '*.git/*', '*./tmp/*', '*/node_modules/*', '*/package-lock.json/*' },
            db_safe_mode = false,
            auto_validate = true,
          }
        }
      }
      local option = { noremap = true, silent = true }

      vim.keymap.set('n', '<Space>f', '<Cmd>Telescope find_files<CR>', option)
      vim.keymap.set('n', '<Space>fg', '<Cmd>Telescope git_files<CR>', option)
      vim.keymap.set('n', '<Space>r', '<Cmd>Telescope live_grep<CR>', option)
      vim.keymap.set('n', '<Space>g', '<Cmd>Telescope grep_string<CR>', option)
    end
  }
  use {
    "nvim-telescope/telescope-frecency.nvim",
    config = function()
      require("telescope").load_extension("frecency")
    end,
    requires = { "kkharji/sqlite.lua" }
  }

  -----------------------------------------------------
  -- Treesitter
  -----------------------------------------------------
  use {
    'nvim-treesitter/nvim-treesitter',
    run = function()
      local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
      ts_update()
    end,
  }
  use {
    'm-demare/hlargs.nvim',
    requires = { 'nvim-treesitter/nvim-treesitter' }
  }

  -----------------------------------------------------
  -- Git
  -----------------------------------------------------
  use {
    "tpope/vim-fugitive",
    config = function ()
      vim.api.nvim_set_keymap("n", "gb", "<cmd>Git blame<CR>", { noremap = true, silent = true })
      vim.api.nvim_set_keymap("n", "GC", "<cmd>.GBrowse<CR>", { noremap = true, silent = true })
    end
  }
  use { "tpope/vim-rhubarb" }
  use {
    "APZelos/blamer.nvim",
    config = function ()
      vim.api.nvim_exec(
        [[
          let g:blamer_enabled = 1
          let g:blamer_delay = 100
          let g:blamer_show_in_visual_mode = 0
          let g:blamer_show_in_insert_mode = 0
          let g:blamer_date_format = '%y/%m/%d %H:%M'
        ]],
        false
      )
    end
  }

  -----------------------------------------------------
  -- Startup screen
  -----------------------------------------------------
  use {
    'goolord/alpha-nvim',
    requires = { 'nvim-tree/nvim-web-devicons' },
    config = function ()
      local alpha = require('alpha')
      local dashboard = require('alpha.themes.dashboard')
      dashboard.section.header.val = vim.fn.readfile(vim.fn.expand("~/.config/nvim/lua/dashboard_custom_header.txt"))
      alpha.setup(dashboard.config)
    end
  }

  -----------------------------------------------------
  -- Markdown Preview
  -----------------------------------------------------
  use({ "iamcco/markdown-preview.nvim", run = "cd app && npm install", setup = function() vim.g.mkdp_filetypes = { "markdown" } end, ft = { "markdown" }, })

  -----------------------------------------------------
  -- Copilot
  -----------------------------------------------------
  use({ "github/copilot.vim", })
end)

