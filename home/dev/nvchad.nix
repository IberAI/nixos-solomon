# home/dev/nvchad.nix
{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.nix4nvchad.homeManagerModules.default
  ];

  programs.nvchad = {
    enable = true;

    # Copy config into ~/.config/nvim so NvChad can write files.
    hm-activation = true;

    # Keep backups of prior configs when switching.
    backup = true;

    extraPackages = with pkgs; [
      ########################################
      # Editor parsing / Treesitter
      ########################################

      tree-sitter

      ########################################
      # Nix LSP / formatter / diagnostics
      ########################################

      nixd
      alejandra
      deadnix
      statix

      ########################################
      # Lua LSP / formatter
      ########################################

      lua-language-server
      stylua

      ########################################
      # Web LSPs
      ########################################

      nodePackages.typescript-language-server
      nodePackages.vscode-langservers-extracted
      nodePackages.svelte-language-server

      ########################################
      # Deno / Supabase Edge Functions
      ########################################
      #
      # Supabase Edge Functions run on Deno.
      # This package provides:
      # - deno
      # - deno lsp
      # - deno fmt
      # - deno lint
      # - deno check
      #
      # Neovim's denols config below uses:
      #   cmd = { "deno", "lsp" }
      ########################################

      deno

      ########################################
      # Web formatters
      ########################################

      nodePackages.prettier

      ########################################
      # Shell LSP / formatter / linter
      ########################################

      bash-language-server
      shfmt
      shellcheck

      ########################################
      # Python LSP / formatter / linter
      ########################################

      pyright
      ruff
      python3Packages.black
      python3Packages.isort

      ########################################
      # Markdown / YAML / TOML
      ########################################

      marksman
      yaml-language-server
      taplo
    ];

    extraConfig = ''
      -- =========================
      -- Basics
      -- =========================
      vim.opt.number = true
      vim.opt.relativenumber = true
      vim.opt.scrolloff = 5
      vim.opt.sidescrolloff = 8
      vim.opt.clipboard = "unnamedplus"
      vim.opt.completeopt = { "menuone", "noselect" }
      vim.opt.swapfile = false
      vim.opt.undofile = true
      vim.opt.updatetime = 250
      vim.opt.timeoutlen = 400
      vim.opt.signcolumn = "yes"

      -- =========================
      -- Diagnostics
      -- =========================
      vim.diagnostic.config({
        virtual_text = {
          spacing = 4,
          source = "if_many",
        },
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = {
          border = "rounded",
          source = "if_many",
        },
      })

      -- =========================
      -- Treesitter
      -- =========================
      pcall(function()
        require("nvim-treesitter.configs").setup({
          ensure_installed = {
            "nix",
            "lua",
            "vim",
            "vimdoc",

            "typescript",
            "tsx",
            "javascript",
            "html",
            "css",
            "json",
            "svelte",

            "bash",
            "python",
            "markdown",
            "markdown_inline",
            "yaml",
            "toml",
          },
          highlight = { enable = true },
          indent = { enable = true },

          -- Important for your rule:
          -- do not let Neovim try to compile/install parsers itself.
          auto_install = false,
        })
      end)

      -- =========================
      -- Native LSP config
      -- Neovim 0.11+ style
      -- =========================
      -- Uses vim.lsp.config and vim.lsp.enable.
      -- No require("lspconfig") here.
      -- =========================

      local capabilities = vim.lsp.protocol.make_client_capabilities()

      pcall(function()
        capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)
      end)

      -- Helper:
      -- Detect whether a file belongs to a Deno project.
      --
      -- Supabase Edge Functions should have one of these files:
      --   supabase/functions/<function-name>/deno.json
      --   supabase/functions/<function-name>/deno.jsonc
      --   supabase/functions/import_map.json
      --
      -- This lets Neovim use denols for Edge Functions and ts_ls for normal
      -- Node/React/Svelte TypeScript projects.
      local function is_deno_project(fname)
        return vim.fs.root(fname, {
          "deno.json",
          "deno.jsonc",
          "import_map.json",
          "import_map.jsonc",
        }) ~= nil
      end

      vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy",
        callback = function()
          vim.lsp.config("*", {
            capabilities = capabilities,
            root_markers = { ".git" },
          })

          -- =========================
          -- Nix
          -- =========================

          vim.lsp.config("nixd", {
            cmd = { "nixd" },
            filetypes = { "nix" },
            root_markers = {
              "flake.nix",
              "default.nix",
              "shell.nix",
              ".git",
            },
          })

          -- =========================
          -- Lua
          -- =========================

          vim.lsp.config("lua_ls", {
            cmd = { "lua-language-server" },
            filetypes = { "lua" },
            root_markers = {
              ".luarc.json",
              ".luarc.jsonc",
              ".stylua.toml",
              "stylua.toml",
              ".git",
            },
            settings = {
              Lua = {
                runtime = {
                  version = "LuaJIT",
                },
                diagnostics = {
                  globals = { "vim" },
                },
                workspace = {
                  checkThirdParty = false,
                },
                telemetry = {
                  enable = false,
                },
              },
            },
          })

          -- =========================
          -- Deno / Supabase Edge Functions
          -- =========================
          --
          -- This is the important part for Supabase Edge Functions.
          --
          -- denols will only start when it finds one of:
          --   deno.json
          --   deno.jsonc
          --   import_map.json
          --   import_map.jsonc
          --
          -- So for each Supabase function, prefer this structure:
          --
          --   supabase/functions/
          --     my-function/
          --       index.ts
          --       deno.json
          --
          -- Example deno.json:
          --
          --   {
          --     "imports": {
          --       "@supabase/supabase-js": "npm:@supabase/supabase-js@2"
          --     },
          --     "lint": {
          --       "rules": {
          --         "tags": ["recommended"]
          --       }
          --     },
          --     "fmt": {
          --       "semiColons": false,
          --       "singleQuote": true
          --     }
          --   }
          --
          -- That gives you:
          -- - Deno-aware imports
          -- - Deno.env autocomplete
          -- - URL/npm/jsr import support
          -- - diagnostics for Edge Functions
          -- - less conflict with Node TypeScript tooling
          -- =========================

          vim.lsp.config("denols", {
            cmd = { "deno", "lsp" },
            filetypes = {
              "javascript",
              "javascriptreact",
              "typescript",
              "typescriptreact",
            },
            root_markers = {
              "deno.json",
              "deno.jsonc",
              "import_map.json",
              "import_map.jsonc",
            },
            settings = {
              deno = {
                enable = true,
                lint = true,

                -- Many Supabase/Deno APIs are stable now, but keeping this true
                -- is useful for projects that use APIs/extensions that still
                -- require unstable flags.
                unstable = true,

                suggest = {
                  imports = {
                    hosts = {
                      ["https://deno.land"] = true,
                      ["https://esm.sh"] = true,
                      ["https://jsr.io"] = true,
                    },
                  },
                },
              },
            },
          })

          -- =========================
          -- TypeScript / JavaScript
          -- =========================
          --
          -- ts_ls is for normal Node/React/Svelte/etc TypeScript.
          --
          -- Important:
          -- We intentionally prevent ts_ls from attaching inside Deno projects.
          -- Otherwise both ts_ls and denols may attach to the same Edge Function
          -- file and fight over diagnostics, imports, and type resolution.
          -- =========================

          vim.lsp.config("ts_ls", {
            cmd = { "typescript-language-server", "--stdio" },
            filetypes = {
              "javascript",
              "javascriptreact",
              "typescript",
              "typescriptreact",
            },
            root_markers = {
              "package.json",
              "tsconfig.json",
              "jsconfig.json",
              ".git",
            },

            root_dir = function(bufnr, on_dir)
              local fname = vim.api.nvim_buf_get_name(bufnr)

              -- If this file belongs to a Deno/Supabase Edge Function project,
              -- do not start ts_ls. denols should handle it.
              if is_deno_project(fname) then
                return
              end

              local root = vim.fs.root(fname, {
                "package.json",
                "tsconfig.json",
                "jsconfig.json",
                ".git",
              })

              if root then
                on_dir(root)
              end
            end,
          })

          -- =========================
          -- ESLint
          -- =========================
          -- vscode-eslint-language-server is provided by
          -- vscode-langservers-extracted in many nixpkgs versions.
          --
          -- Important:
          -- ESLint is usually for Node projects. Supabase Edge Functions usually
          -- use deno lint instead.
          --
          -- This config prevents ESLint from attaching inside Deno projects
          -- to avoid noisy or wrong diagnostics.
          -- =========================

          vim.lsp.config("eslint", {
            cmd = { "vscode-eslint-language-server", "--stdio" },
            filetypes = {
              "javascript",
              "javascriptreact",
              "typescript",
              "typescriptreact",
              "svelte",
            },
            root_markers = {
              ".eslintrc",
              ".eslintrc.js",
              ".eslintrc.cjs",
              ".eslintrc.json",
              "eslint.config.js",
              "eslint.config.mjs",
              "eslint.config.cjs",
              "package.json",
              ".git",
            },
            root_dir = function(bufnr, on_dir)
              local fname = vim.api.nvim_buf_get_name(bufnr)

              -- Do not run ESLint inside Deno/Supabase Edge Function folders.
              -- Use deno lint there.
              if is_deno_project(fname) then
                return
              end

              local root = vim.fs.root(fname, {
                ".eslintrc",
                ".eslintrc.js",
                ".eslintrc.cjs",
                ".eslintrc.json",
                "eslint.config.js",
                "eslint.config.mjs",
                "eslint.config.cjs",
                "package.json",
                ".git",
              })

              if root then
                on_dir(root)
              end
            end,
            settings = {
              workingDirectories = { mode = "auto" },
            },
          })

          -- =========================
          -- HTML / CSS / JSON
          -- =========================

          vim.lsp.config("html", {
            cmd = { "vscode-html-language-server", "--stdio" },
            filetypes = { "html" },
            root_markers = { "package.json", ".git" },
          })

          vim.lsp.config("cssls", {
            cmd = { "vscode-css-language-server", "--stdio" },
            filetypes = { "css", "scss", "less" },
            root_markers = { "package.json", ".git" },
          })

          vim.lsp.config("jsonls", {
            cmd = { "vscode-json-language-server", "--stdio" },
            filetypes = { "json", "jsonc" },
            root_markers = { "package.json", ".git" },
          })

          -- =========================
          -- Svelte
          -- =========================

          vim.lsp.config("svelte", {
            cmd = { "svelteserver", "--stdio" },
            filetypes = { "svelte" },
            root_markers = {
              "svelte.config.js",
              "svelte.config.cjs",
              "package.json",
              ".git",
            },
          })

          -- =========================
          -- Shell
          -- =========================

          vim.lsp.config("bashls", {
            cmd = { "bash-language-server", "start" },
            filetypes = { "sh", "bash" },
            root_markers = { ".git" },
          })

          -- =========================
          -- Python
          -- =========================

          vim.lsp.config("pyright", {
            cmd = { "pyright-langserver", "--stdio" },
            filetypes = { "python" },
            root_markers = {
              "pyproject.toml",
              "setup.py",
              "setup.cfg",
              "requirements.txt",
              ".git",
            },
          })

          -- =========================
          -- Markdown / YAML / TOML
          -- =========================

          vim.lsp.config("marksman", {
            cmd = { "marksman", "server" },
            filetypes = { "markdown", "markdown.mdx" },
            root_markers = { ".marksman.toml", ".git" },
          })

          vim.lsp.config("yamlls", {
            cmd = { "yaml-language-server", "--stdio" },
            filetypes = { "yaml", "yml" },
            root_markers = { ".git" },
          })

          vim.lsp.config("taplo", {
            cmd = { "taplo", "lsp", "stdio" },
            filetypes = { "toml" },
            root_markers = { "taplo.toml", ".taplo.toml", ".git" },
          })

          -- =========================
          -- Enable LSP servers
          -- =========================
          --
          -- denols is now enabled.
          -- It will only attach in folders with deno.json/deno.jsonc/import_map.
          -- ts_ls will avoid those folders because of root_dir above.
          -- =========================

          vim.lsp.enable({
            "nixd",
            "lua_ls",
            "denols",
            "ts_ls",
            "eslint",
            "html",
            "cssls",
            "jsonls",
            "svelte",
            "bashls",
            "pyright",
            "marksman",
            "yamlls",
            "taplo",
          })

          -- =========================
          -- LSP keymaps
          -- =========================

          vim.api.nvim_create_autocmd("LspAttach", {
            callback = function(event)
              local opts = { buffer = event.buf, silent = true }

              vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
              vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
              vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
              vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
              vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
              vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
              vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
              vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
              vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
            end,
          })

          -- =========================
          -- Formatting
          -- =========================
          -- NvChad includes conform.nvim in current setups.
          -- This is wrapped in pcall so your config still opens
          -- even if conform is unavailable.
          --
          -- Important for Deno:
          -- Conform supports deno_fmt, but we do not force deno_fmt for all
          -- TypeScript files because that would also affect normal Node projects.
          --
          -- Recommended workflow:
          --   - Use Prettier for normal JS/TS/Svelte/frontend files.
          --   - Use deno fmt manually for Edge Functions:
          --
          --       deno fmt supabase/functions
          --
          -- Or inside Neovim:
          --   <leader>df
          --
          -- That keeps Supabase Edge Function formatting correct without breaking
          -- your normal frontend formatting.
          -- =========================

          pcall(function()
            local conform = require("conform")

            conform.setup({
              formatters_by_ft = {
                nix = { "alejandra" },
                lua = { "stylua" },

                javascript = { "prettier" },
                javascriptreact = { "prettier" },
                typescript = { "prettier" },
                typescriptreact = { "prettier" },
                svelte = { "prettier" },
                html = { "prettier" },
                css = { "prettier" },
                scss = { "prettier" },
                less = { "prettier" },
                json = { "prettier" },
                jsonc = { "prettier" },
                markdown = { "prettier" },
                yaml = { "prettier" },

                sh = { "shfmt" },
                bash = { "shfmt" },

                python = { "ruff_format", "ruff_organize_imports" },
              },

              format_on_save = {
                timeout_ms = 1000,
                lsp_format = "fallback",
              },
            })

            vim.keymap.set("n", "<leader>fm", function()
              conform.format({
                async = true,
                lsp_format = "fallback",
              })
            end, { desc = "Format buffer" })
          end)
        end,
      })
    '';
  };
}
