return {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    opts = function()
        local opts = {
            terminal = {
                snacks_win_opts = {
                    -- snacks draws its windows with NormalFloat, which has a solid
                    -- background; use the editor's own (transparent) one instead
                    wo = {
                        winhighlight = "Normal:Normal,NormalNC:NormalNC,WinBar:SnacksWinBar,WinBarNC:SnacksWinBarNC,WinSeparator:WinSeparator",
                    },
                },
            },
        }

        -- the native installer puts claude in ~/.local/bin, which a shell started
        -- before the install (or on Windows, before PATH was updated) won't have
        local local_claude = vim.fn.expand("~/.local/bin/claude" .. (vim.fn.has("win32") == 1 and ".exe" or ""))
        if vim.fn.executable("claude") == 0 and vim.fn.executable(local_claude) == 1 then
            opts.terminal_cmd = local_claude
        end

        return opts
    end,
    cmd = {
        "ClaudeCode",
        "ClaudeCodeFocus",
        "ClaudeCodeSelectModel",
        "ClaudeCodeAdd",
        "ClaudeCodeSend",
        "ClaudeCodeStatus",
        "ClaudeCodeDiffAccept",
        "ClaudeCodeDiffDeny",
        "ClaudeCodeCloseAllDiffs",
    },
    keys = {
        { "<leader>cc", "<cmd>ClaudeCode<cr>", desc = "Claude Code: toggle" },
        { "<leader>cf", "<cmd>ClaudeCodeFocus<cr>", desc = "Claude Code: focus" },
        { "<leader>cr", "<cmd>ClaudeCode --resume<cr>", desc = "Claude Code: resume" },
        { "<leader>cC", "<cmd>ClaudeCode --continue<cr>", desc = "Claude Code: continue" },
        { "<leader>cm", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Claude Code: select model" },
        { "<leader>cb", "<cmd>ClaudeCodeAdd %<cr>", desc = "Claude Code: add current buffer" },
        { "<leader>cs", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Claude Code: send selection" },
        { "<leader>cA", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Claude Code: accept diff" },
        { "<leader>cD", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Claude Code: reject diff" },
    },
}
