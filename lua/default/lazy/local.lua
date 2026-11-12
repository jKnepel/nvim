local local_plugins = {
    {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            local harpoon = require("harpoon")

            harpoon:setup()

            vim.keymap.set("n", "<leader>A", function()
                harpoon:list():prepend()
            end, { desc = "Harpoon: prepend file" })
            vim.keymap.set("n", "<leader>a", function()
                harpoon:list():add()
            end, { desc = "Harpoon: add file" })
            vim.keymap.set("n", "<C-e>", function()
                harpoon.ui:toggle_quick_menu(harpoon:list())
            end, { desc = "Harpoon: toggle menu" })

            vim.keymap.set("n", "<M-1>", function()
                harpoon:list():select(1)
            end, { desc = "Harpoon: go to file 1" })
            vim.keymap.set("n", "<M-2>", function()
                harpoon:list():select(2)
            end, { desc = "Harpoon: go to file 2" })
            vim.keymap.set("n", "<M-3>", function()
                harpoon:list():select(3)
            end, { desc = "Harpoon: go to file 3" })
            vim.keymap.set("n", "<M-4>", function()
                harpoon:list():select(4)
            end, { desc = "Harpoon: go to file 4" })
        end,
    },
}

return local_plugins
