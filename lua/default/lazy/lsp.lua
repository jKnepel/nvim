return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "stevearc/conform.nvim",
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        "hrsh7th/nvim-cmp",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
        "j-hui/fidget.nvim",
    },

    config = function()
        local cmp = require("cmp")
        local cmp_lsp = require("cmp_nvim_lsp")
        local capabilities = vim.tbl_deep_extend(
            "force",
            {},
            vim.lsp.protocol.make_client_capabilities(),
            cmp_lsp.default_capabilities()
        )

        require("fidget").setup({})

        -- vim.lsp.config() only describes a server; vim.lsp.enable() turns it on.
        -- "*" applies to every server.
        vim.lsp.config("*", {
            capabilities = capabilities,
        })

        vim.lsp.config("zls", {
            root_markers = { ".git", "build.zig", "zls.json" },
            settings = {
                zls = {
                    enable_inlay_hints = true,
                    enable_snippets = true,
                    warn_style = true,
                },
            },
        })
        vim.g.zig_fmt_parse_errors = 0
        vim.g.zig_fmt_autosave = 0

        vim.lsp.config("lua_ls", {
            settings = {
                Lua = {
                    runtime = {
                        version = "LuaJIT",
                    },
                    diagnostics = {
                        globals = { "vim" },
                    },
                    workspace = {
                        library = vim.api.nvim_get_runtime_file("", true),
                        checkThirdParty = false,
                    },
                    format = {
                        enable = true,
                        -- Put format options here
                        -- NOTE: the value should be STRING!!
                        defaultConfig = {
                            indent_style = "space",
                            indent_size = "4",
                        },
                    },
                },
            },
        })

        vim.lsp.config("tailwindcss", {
            filetypes = {
                "html",
                "css",
                "scss",
                "javascript",
                "javascriptreact",
                "typescript",
                "typescriptreact",
                "vue",
                "svelte",
                "heex",
            },
        })

        vim.lsp.config("clangd", {
            cmd = {
                "clangd",
                "--background-index",
                "--clang-tidy",
                "--header-insertion=never",
                "--completion-style=detailed",
            },
        })

        -- TypeScript: TS 7 (native Go) ships no tsserver.js, only `tsc --lsp`.
        -- Projects with TS >= 7 in node_modules use that server; everything else uses vtsls.
        local ts_filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" }

        local function ts7_root(bufnr)
            local root = vim.fs.root(bufnr, { "pnpm-lock.yaml", "package-lock.json", "yarn.lock", "bun.lock", ".git" })
            if not root then
                return nil
            end
            local pkg = vim.fs.joinpath(root, "node_modules", "typescript", "package.json")
            local ok, data = pcall(function()
                return vim.json.decode(table.concat(vim.fn.readfile(pkg), "\n"))
            end)
            local major = ok and data and data.version and tonumber(data.version:match("^(%d+)"))
            if major and major >= 7 then
                return root
            end
        end

        -- tsgo registers file watchers as absolute globs with a lowercased drive
        -- (and sometimes a fully lowercased path): "c:/users/...". Neovim matches
        -- globs case-sensitively against "C:/Users/...", so no change made outside
        -- the editor (git, Claude, codegen) ever reached the server. Rewrite each
        -- glob's path prefix to the workspace root's real casing.
        local function fix_watch_globs(params, client)
            for _, reg in ipairs(params.registrations or {}) do
                local watchers = reg.method == "workspace/didChangeWatchedFiles"
                    and reg.registerOptions
                    and reg.registerOptions.watchers
                for _, w in ipairs(watchers or {}) do
                    local g = w.globPattern
                    if type(g) == "string" and g:match("^%a:") then
                        g = g:gsub("^%a:", string.upper)
                        for _, folder in ipairs(client.workspace_folders or {}) do
                            local root = vim.fs.normalize(vim.uri_to_fname(folder.uri))
                            if g:sub(1, #root + 1):lower() == (root .. "/"):lower() then
                                g = root .. g:sub(#root + 1)
                                break
                            end
                        end
                        w.globPattern = g
                    end
                end
            end
        end

        vim.lsp.config("ts_native", {
            handlers = {
                ["client/registerCapability"] = function(err, params, ctx)
                    local client = vim.lsp.get_client_by_id(ctx.client_id)
                    if params and client then
                        fix_watch_globs(params, client)
                    end
                    return vim.lsp.handlers["client/registerCapability"](err, params, ctx)
                end,
            },
            filetypes = ts_filetypes,
            root_dir = function(bufnr, on_dir)
                local root = ts7_root(bufnr)
                if root then
                    on_dir(root)
                end
            end,
            cmd = function(dispatchers, config)
                local tsc = vim.fs.joinpath(config.root_dir, "node_modules", "typescript", "bin", "tsc")
                return vim.lsp.rpc.start({ "node", tsc, "--lsp", "--stdio" }, dispatchers, { cwd = config.root_dir })
            end,
        })
        vim.lsp.enable("ts_native")

        vim.lsp.config("vtsls", {
            root_dir = function(bufnr, on_dir)
                if ts7_root(bufnr) then
                    return
                end
                local root = vim.fs.root(bufnr, { "tsconfig.json", "jsconfig.json", "package.json", ".git" })
                if root then
                    on_dir(root)
                end
            end,
        })

        local ensure_installed = {
            "lua_ls",
            "rust_analyzer",
            "vtsls",
            "tailwindcss",
        }
        -- mason builds gopls with `go install`, so only request it when Go is on PATH
        if vim.fn.executable("go") == 1 then
            table.insert(ensure_installed, "gopls")
        end

        require("mason").setup()
        -- mason-lspconfig enables every server mason installed (automatic_enable)
        require("mason-lspconfig").setup({
            ensure_installed = ensure_installed,
        })

        -- clangd comes from the system (pacman / LLVM on Windows), not mason, so enable it ourselves
        vim.lsp.enable("clangd")

        local cmp_select = { behavior = cmp.SelectBehavior.Select }

        cmp.setup({
            snippet = {
                expand = function(args)
                    require("luasnip").lsp_expand(args.body) -- For `luasnip` users.
                end,
            },
            mapping = cmp.mapping.preset.insert({
                ["<C-p>"] = cmp.mapping.select_prev_item(cmp_select), -- Completion: previous item
                ["<C-n>"] = cmp.mapping.select_next_item(cmp_select), -- Completion: next item
                ["<C-y>"] = cmp.mapping.confirm({ select = true }), -- Completion: confirm
                ["<C-Space>"] = cmp.mapping.complete(), -- Completion: open menu
            }),
            sources = cmp.config.sources({
                { name = "nvim_lsp" },
                { name = "luasnip" }, -- For luasnip users.
            }, {
                { name = "buffer" },
            }),
        })

        vim.diagnostic.config({
            -- update_in_insert = true,
            float = {
                focusable = false,
                style = "minimal",
                border = "rounded",
                source = true,
                header = "",
                prefix = "",
            },
        })
    end,
}
