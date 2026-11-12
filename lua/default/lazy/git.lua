return {
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
