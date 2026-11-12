return {
    "stevearc/conform.nvim",
    opts = {},
    config = function()
        require("conform").setup({
            format_on_save = {
                timeout_ms = 5000,
                lsp_format = "fallback",
            },
            formatters_by_ft = {
                c = { "clang-format" },
                cpp = { "clang-format" },
                lua = { "stylua" },
                go = { "gofmt" },
                -- oxfmt only runs in projects with an oxfmt config; otherwise prettier
                javascript = { "oxfmt", "prettier", stop_after_first = true },
                javascriptreact = { "oxfmt", "prettier", stop_after_first = true },
                typescript = { "oxfmt", "prettier", stop_after_first = true },
                typescriptreact = { "oxfmt", "prettier", stop_after_first = true },
                json = { "oxfmt", "prettier", stop_after_first = true },
                jsonc = { "oxfmt", "prettier", stop_after_first = true },
            },
            formatters = {
                oxfmt = {
                    condition = function(_, ctx)
                        return vim.fs.find({ ".oxfmtrc.json", ".oxfmtrc.jsonc", "oxfmt.config.ts" }, {
                            upward = true,
                            path = ctx.dirname,
                        })[1] ~= nil
                    end,
                },
                prettier = {
                    prepend_args = { "--tab-width", "4" },
                },
                ["clang-format"] = {
                    -- use the project's .clang-format if there is one, otherwise LLVM with 4-space indents
                    prepend_args = function(_, ctx)
                        local config = vim.fs.find({ ".clang-format", "_clang-format" }, {
                            upward = true,
                            path = ctx.dirname,
                        })[1]
                        if config then
                            return { "-style=file" }
                        end
                        return { "-style={BasedOnStyle: LLVM, IndentWidth: 4}" }
                    end,
                },
            },
        })

        vim.keymap.set("n", "<leader>f", function()
            require("conform").format({ bufnr = 0 })
        end, { desc = "Format buffer" })
    end,
}
