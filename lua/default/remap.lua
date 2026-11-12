vim.g.mapleader = " "

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

vim.keymap.set("n", "J", "mzJ`z", { desc = "Join lines, keep cursor in place" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half page down, centered" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half page up, centered" })
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search match, centered" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search match, centered" })
vim.keymap.set("n", "=ap", "ma=ap'a", { desc = "Reindent paragraph, keep cursor in place" })

vim.keymap.set("x", "<leader>p", [["_dP]], { desc = "Paste over selection without yanking it" })
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank to system clipboard" })
vim.keymap.set("n", "<leader>Y", [["+Y]], { desc = "Yank line to system clipboard" })
vim.keymap.set({ "n", "v" }, "<leader>d", '"_d', { desc = "Delete without yanking" })

vim.keymap.set("i", "<C-c>", "<Esc>", { desc = "Escape insert mode" })
vim.keymap.set("t", "<C-q>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })

vim.keymap.set("n", "Q", "<nop>", { desc = "Disabled (Ex mode)" })

vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz", { desc = "Next quickfix item" })
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz", { desc = "Previous quickfix item" })

vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
    { desc = "Substitute word under cursor in file" })
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>",
    { silent = true, desc = "Make current file executable (chmod +x)" })

vim.keymap.set("n", "<leader>ca", function()
    -- the animation needs a tree-sitter parser for the current buffer
    local ok, parser = pcall(vim.treesitter.get_parser)
    if not ok or not parser then
        vim.notify("game_of_life: no tree-sitter parser for this buffer", vim.log.levels.WARN)
        return
    end
    require("cellular-automaton").start_animation("game_of_life")
end, { desc = "Game of Life animation" })

vim.keymap.set("n", "<leader><leader>", function()
    vim.cmd("so")
end, { desc = "Source current file" })
