return {
    {
        "L3MON4D3/LuaSnip",
        -- follow latest release.
        version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
        -- install jsregexp (optional!).
        -- skipped where make is missing (stock Windows), luasnip works without it
        build = vim.fn.executable("make") == 1 and "make install_jsregexp" or nil,

        dependencies = { "rafamadriz/friendly-snippets" },

        config = function()
            local ls = require("luasnip")
            ls.filetype_extend("javascript", { "jsdoc" })

            --- TODO: What is expand?
            vim.keymap.set({ "i" }, "<C-s>e", function()
                ls.expand()
            end, { silent = true, desc = "Snippet: expand" })

            vim.keymap.set({ "i", "s" }, "<C-s>;", function()
                ls.jump(1)
            end, { silent = true, desc = "Snippet: jump to next field" })
            vim.keymap.set({ "i", "s" }, "<C-s>,", function()
                ls.jump(-1)
            end, { silent = true, desc = "Snippet: jump to previous field" })

            vim.keymap.set({ "i", "s" }, "<C-E>", function()
                if ls.choice_active() then
                    ls.change_choice(1)
                end
            end, { silent = true, desc = "Snippet: next choice" })
        end,
    },
}
