return {
    "nvim-telescope/telescope.nvim",

    tag = "v0.2.2",

    dependencies = {
        "nvim-lua/plenary.nvim",
    },

    config = function()
        require("telescope").setup({})

        local preview_utils = require("telescope.previewers.utils")
        preview_utils.ts_highlighter = function(bufnr, ft)
            -- ft is nil for extensions Neovim doesn't recognise, and get_lang errors on nil
            if not ft or ft == "" then
                return false
            end

            local lang = vim.treesitter.language.get_lang(ft) or ft
            return pcall(vim.treesitter.start, bufnr, lang)
        end

        local builtin = require("telescope.builtin")
        vim.keymap.set("n", "<leader>pf", builtin.find_files, { desc = "Telescope: find files" })
        vim.keymap.set("n", "<C-f>", builtin.git_files, { desc = "Telescope: find git files" })
        vim.keymap.set("n", "<leader>pws", function()
            local word = vim.fn.expand("<cword>")
            builtin.grep_string({ search = word })
        end, { desc = "Telescope: grep word under cursor" })
        vim.keymap.set("n", "<leader>ps", function()
            builtin.grep_string({ search = vim.fn.input("Grep > ") })
        end, { desc = "Telescope: grep for input" })
        vim.keymap.set("n", "<leader>vh", builtin.help_tags, { desc = "Telescope: help tags" })
    end,
}
