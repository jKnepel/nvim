-- `nvim +Fresh` starts without restoring and deletes this directory's session,
-- e.g. when a restored terminal crashes on startup
local fresh = vim.tbl_contains(vim.v.argv, "+Fresh")

-- The Claude Code window can't be saved as it is: its terminal, restored by the session,
-- fails to start and aborts the whole restore, and even if it started it would have no
-- IDE connection and an empty conversation. So when saving, its window shows a
-- placeholder buffer instead, which keeps its place in the layout. On restore, Claude
-- is reopened through the plugin with `--continue` and the placeholder closed.
local PLACEHOLDER = "claude-code.placeholder"
local PLACEHOLDER_FILETYPE = "claudecode_placeholder"

local function is_claude_terminal(name)
    return name:match("^term://.*[/\\]claude[^/\\]*$") ~= nil
end

local function claude_buf()
    -- the plugin loads on first use, so an unloaded module means no Claude terminal
    local terminal = package.loaded["claudecode.terminal"]
    return terminal and terminal.get_active_terminal_bufnr()
end

local function claude_is_open()
    return claude_buf() ~= nil
end

local function is_claude_window(win)
    local buf = vim.api.nvim_win_get_buf(win)
    return buf == claude_buf() or is_claude_terminal(vim.api.nvim_buf_get_name(buf))
end

local function is_placeholder_window(win)
    return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(win)), ":t") == PLACEHOLDER
end

local function normal_windows(tab)
    return vim.tbl_filter(function(win)
        return vim.api.nvim_win_get_config(win).relative == ""
    end, vim.api.nvim_tabpage_list_wins(tab))
end

local function split_windows(tab)
    local claude, others = nil, {}
    for _, win in ipairs(normal_windows(tab)) do
        if is_claude_window(win) then
            claude = win
        else
            table.insert(others, win)
        end
    end
    return claude, others
end

-- shows buf in win without autocommands, as snacks moves any other buffer out of its
-- windows (changing windows' buffers doesn't resize anything, unlike opening/closing them)
local function set_buf_quietly(win, buf)
    local eventignore = vim.o.eventignore
    vim.o.eventignore = "all"
    local ok, err = pcall(vim.api.nvim_win_set_buf, win, buf)
    vim.o.eventignore = eventignore
    if not ok then
        error(err)
    end
end

-- Closing and reopening Claude resizes the other windows, so the sizes are saved again
-- here, as fractions of the editor like the session file does, and reapplied once
-- Claude is back.

local function capture_layout()
    local function size(win)
        return {
            width = vim.api.nvim_win_get_width(win) / vim.o.columns,
            height = vim.api.nvim_win_get_height(win) / vim.o.lines,
        }
    end

    local tabs = {}
    for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
        local claude, others = split_windows(tab)
        local saved = { windows = vim.tbl_map(size, others) }
        saved.claude = claude and size(claude)
        table.insert(tabs, saved)
    end
    return tabs
end

-- windows whose width/height is free to set: those beside another window in a row
-- (width) or in a column (height); setting the height of a window that fills the
-- whole height would change 'cmdheight' instead
local function resizable_directions(tab)
    local directions = {}
    local function walk(node, in_row, in_col)
        if node[1] == "leaf" then
            directions[node[2]] = { width = in_row, height = in_col }
        else
            for _, child in ipairs(node[2]) do
                walk(child, in_row or node[1] == "row", in_col or node[1] == "col")
            end
        end
    end
    walk(vim.fn.winlayout(vim.api.nvim_tabpage_get_number(tab)), false, false)
    return directions
end

local function apply_layout(tabs)
    for i, tab in ipairs(vim.api.nvim_list_tabpages()) do
        local saved = tabs[i]
        local claude, others = split_windows(tab)
        -- windows come back in the saved order, only Claude moves; skip a tab
        -- whose windows don't line up with what was saved
        if saved and #saved.windows == #others then
            local sizes = {}
            for j, win in ipairs(others) do
                sizes[win] = saved.windows[j]
            end
            if claude and saved.claude then
                sizes[claude] = saved.claude
            end

            local directions = resizable_directions(tab)
            -- twice, as resizing one window shifts its neighbors (the session file does the same)
            for _ = 1, 2 do
                for win, size in pairs(sizes) do
                    if directions[win] and directions[win].width then
                        vim.api.nvim_win_set_width(win, math.max(1, math.floor(size.width * vim.o.columns + 0.5)))
                    end
                    if directions[win] and directions[win].height then
                        vim.api.nvim_win_set_height(win, math.max(1, math.floor(size.height * vim.o.lines + 0.5)))
                    end
                end
            end
        end
    end
end

-- saving ---------------------------------------------------------------------------

local function placeholder_buf()
    local buf = vim.fn.bufadd(vim.fn.getcwd() .. "/" .. PLACEHOLDER)
    vim.fn.bufload(buf)
    vim.bo[buf].buflisted = false
    vim.bo[buf].bufhidden = "wipe"
    vim.bo[buf].swapfile = false
    vim.bo[buf].modifiable = false
    vim.bo[buf].filetype = PLACEHOLDER_FILETYPE
    return buf
end

-- snacks closes its terminal windows on ExitPre, which would close the placeholder
-- (resizing the others) or, with Claude focused, cancel the :qa altogether
local function keep_snacks_from_closing_claude()
    local ok, terminals = pcall(function()
        return Snacks.terminal.list()
    end)
    for _, terminal in ipairs(ok and terminals or {}) do
        if terminal.buf == claude_buf() and terminal.augroup then
            for _, autocmd in ipairs(vim.api.nvim_get_autocmds({ group = terminal.augroup, event = "ExitPre" })) do
                pcall(vim.api.nvim_del_autocmd, autocmd.id)
            end
        end
    end
end

-- state of the save in progress: the layout, whether Claude runs, and its window
local saving = nil

local function detach_claude()
    local state = { layout = capture_layout(), claude = claude_is_open() }
    local win = split_windows(0)
    if win then
        state.win, state.buf = win, vim.api.nvim_win_get_buf(win)
        set_buf_quietly(win, placeholder_buf())
    end
    return state
end

-- after a save while nvim keeps running (e.g. changing directory), or a cancelled quit
local function reattach_claude(state)
    if state.win and vim.api.nvim_win_is_valid(state.win) and vim.api.nvim_buf_is_valid(state.buf) then
        set_buf_quietly(state.win, state.buf)
    end
end

-- restoring ------------------------------------------------------------------------

local function reopen_claude()
    -- terminals of Claude that weren't on screen are still in the session's buffer list
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if is_claude_terminal(vim.api.nvim_buf_get_name(buf)) then
            pcall(vim.api.nvim_buf_delete, buf, { force = true })
        end
    end

    if vim.g.RestoreClaude then
        vim.g.RestoreClaude = nil
        vim.cmd("ClaudeCode --continue")
    end

    -- after opening Claude, so the placeholder is never the last window
    -- (opening and closing windows resizes the others; restore_layout fixes that)
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        if is_placeholder_window(win) then
            local buf = vim.api.nvim_win_get_buf(win)
            pcall(vim.api.nvim_win_close, win, true)
            pcall(vim.api.nvim_buf_delete, buf, { force = true })
        end
    end
end

local function restore_layout()
    local layout = vim.g.SessionLayout
    vim.g.SessionLayout = nil
    if not layout then
        return
    end

    -- Claude was running but hidden: keep it running, but out of the layout
    local claude = split_windows(0)
    if claude and not (layout[vim.api.nvim_tabpage_get_number(0)] or {}).claude then
        pcall(vim.api.nvim_win_hide, claude)
    end

    vim.schedule(function()
        apply_layout(layout)
    end)

    -- the terminal can report its final size only after startup; resize again if so
    local group = vim.api.nvim_create_augroup("SessionLayoutResize", { clear = true })
    vim.api.nvim_create_autocmd("VimResized", {
        group = group,
        callback = function()
            apply_layout(layout)
        end,
    })
    vim.defer_fn(function()
        pcall(vim.api.nvim_del_augroup_by_id, group)
    end, 2000)
end

return {
    "rmagatti/auto-session",
    lazy = false,
    init = function()
        vim.api.nvim_create_user_command("Fresh", function()
            require("auto-session").delete_session()
        end, { desc = "Delete the session for the current directory" })

        -- created at startup, so it runs before the ExitPre of any snacks terminal;
        -- auto-session saves later, on VimLeavePre
        vim.api.nvim_create_autocmd("ExitPre", {
            callback = function()
                keep_snacks_from_closing_claude()
                saving = detach_claude()
                -- only runs if the quit was cancelled (e.g. unsaved changes)
                vim.schedule(function()
                    if saving and vim.v.exiting == vim.NIL then
                        reattach_claude(saving)
                        saving = nil
                    end
                end)
            end,
        })
    end,
    opts = {
        auto_save = true,
        auto_restore = not fresh,
        close_filetypes_on_save = { "checkhealth", "netrw" },
        -- it closes windows without a file before saving; the placeholder has to stay
        close_unsupported_windows = { preserve_filetypes = { PLACEHOLDER_FILETYPE } },
        pre_save_cmds = {
            function()
                vim.fn.system({ "git", "-C", vim.fn.getcwd(), "rev-parse", "--show-toplevel" })
                if vim.v.shell_error ~= 0 then
                    return false
                end
                -- when quitting, ExitPre has already done this
                if not saving then
                    saving = detach_claude()
                    saving.reattach = true
                end
                return true
            end,
        },
        save_extra_cmds = {
            function()
                local state = saving or { layout = capture_layout(), claude = claude_is_open() }
                local cmds = {
                    "lua vim.g.SessionLayout = vim.json.decode([==[" .. vim.json.encode(state.layout) .. "]==])",
                }
                if state.claude then
                    table.insert(cmds, "let g:RestoreClaude = 1")
                end
                return cmds
            end,
        },
        post_save_cmds = {
            function()
                if saving and saving.reattach then
                    reattach_claude(saving)
                    saving = nil
                end
            end,
        },
        post_restore_cmds = { reopen_claude, restore_layout },
    },
}
