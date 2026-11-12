return {
    {
        -- letters in the sign column for changed lines, like E/W for diagnostics;
        -- the same letters and colors as the Snacks explorer (highlights in colors.lua)
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPre", "BufNewFile" },
        opts = {
            signs = {
                add = { text = "A" },
                change = { text = "M" },
                delete = { text = "D" },
                topdelete = { text = "D" },
                changedelete = { text = "M" },
            },
            -- no signs on every line of a file git doesn't track yet
            attach_to_untracked = false,
            -- staged lines keep their letter, colored green like staged files in the explorer
            signs_staged_enable = true,
            signs_staged = {
                add = { text = "A" },
                change = { text = "M" },
                delete = { text = "D" },
                topdelete = { text = "D" },
                changedelete = { text = "M" },
            },
        },
    },
    {
        "kdheepak/lazygit.nvim",
        cmd = { "LazyGit", "LazyGitCurrentFile", "LazyGitFilter", "LazyGitFilterCurrentFile" },
        dependencies = { "nvim-lua/plenary.nvim" },
        keys = {
            { "<leader>gs", "<cmd>LazyGit<cr>", desc = "Git: lazygit" },
            { "<leader>gl", "<cmd>LazyGitFilterCurrentFile<cr>", desc = "Git: lazygit log of current file" },
        },
    },
    {
        "sindrets/diffview.nvim",
        cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
        keys = {
            {
                "<leader>gd",
                function()
                    if next(require("diffview.lib").views) == nil then
                        vim.cmd("DiffviewOpen")
                    else
                        vim.cmd("DiffviewClose")
                    end
                end,
                desc = "Git: toggle diff of working tree",
            },
            { "<leader>gD", "<cmd>DiffviewOpen develop...HEAD<cr>", desc = "Git: diff branch vs develop" },
            { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "Git: history of current file" },
            { "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "Git: history of branch" },
            { "<leader>gq", "<cmd>DiffviewClose<cr>", desc = "Git: close diffview" },
        },
        opts = {
            -- no nvim-web-devicons in this config
            use_icons = false,
        },
    },
}
