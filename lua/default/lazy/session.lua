-- `nvim +Fresh` starts without restoring and deletes this directory's session,
-- e.g. when a restored terminal crashes on startup
local fresh = vim.tbl_contains(vim.v.argv, "+Fresh")

-- the session saves the Claude Code window as a bare `claude` terminal, which would
-- restart without the plugin's IDE connection and with an empty conversation; instead
-- it is dropped on restore and reopened through the plugin with `--continue`
local function is_claude_terminal(name)
    return name:match("^term://.*[/\\]claude[^/\\]*$") ~= nil
end

local function claude_is_open()
    -- the plugin loads on first use, so an unloaded module means no Claude terminal
    local terminal = package.loaded["claudecode.terminal"]
    return terminal ~= nil and terminal.get_active_terminal_bufnr() ~= nil
end

local function reopen_claude()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if is_claude_terminal(vim.api.nvim_buf_get_name(buf)) then
            pcall(vim.api.nvim_buf_delete, buf, { force = true })
        end
    end

    if vim.g.RestoreClaude then
        vim.g.RestoreClaude = nil
        vim.cmd("ClaudeCode --continue")
    end
end

return {
    "rmagatti/auto-session",
    lazy = false,
    init = function()
        vim.api.nvim_create_user_command("Fresh", function()
            require("auto-session").delete_session()
        end, { desc = "Delete the session for the current directory" })
    end,
    opts = {
        auto_save = true,
        auto_restore = not fresh,
        close_filetypes_on_save = { "checkhealth", "netrw" },
        pre_save = {
            function()
                vim.fn.system({ "git", "-C", vim.fn.getcwd(), "rev-parse", "--show-toplevel" })
                return vim.v.shell_error == 0
            end,
        },
        save_extra_cmds = {
            function()
                if claude_is_open() then
                    return "let g:RestoreClaude = 1"
                end
            end,
        },
        post_restore_cmds = { reopen_claude },
    },
}
