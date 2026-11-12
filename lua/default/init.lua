require("default.set")
require("default.remap")
require("default.lazy_init")

local augroup = vim.api.nvim_create_augroup
local DefaultGroup = augroup("Default", {})

local autocmd = vim.api.nvim_create_autocmd
local yank_group = augroup("HighlightYank", {})

autocmd("TextYankPost", {
    group = yank_group,
    pattern = "*",
    callback = function()
        vim.hl.on_yank({
            higroup = "IncSearch",
            timeout = 40,
        })
    end,
})

autocmd({ "BufWritePre" }, {
    group = DefaultGroup,
    pattern = "*",
    command = [[%s/\s\+$//e]],
})

-- create missing parent directories when writing a file
autocmd("BufWritePre", {
    group = DefaultGroup,
    callback = function(args)
        -- skip non-file buffers like oil:// or scp://
        if args.match:match("^%w+://") then
            return
        end
        vim.fn.mkdir(vim.fn.fnamemodify(args.match, ":p:h"), "p")
    end,
})

-- :mksession saves terminal commands with forward slashes on Windows
-- (term://...//1234:C:/Windows/system32/cmd.exe). Neovim's own term:// handler passes
-- that string to cmd.exe, which reads the slashes as switches and runs `md .exe`
-- instead of the shell. This replacement starts a plain executable path directly.
if vim.fn.has("win32") == 1 then
    vim.api.nvim_clear_autocmds({ group = "nvim.terminal", event = "BufReadCmd", pattern = "term://*" })

    autocmd("BufReadCmd", {
        group = DefaultGroup,
        pattern = "term://*",
        nested = true,
        callback = function(args)
            if vim.b[args.buf].term_title then
                return
            end

            local cmd = vim.fn.matchstr(args.match, [[\c\mterm://\%(.\{-}//\%(\d\+:\)\?\)\?\zs.*]])
            local cwd = vim.fn.matchlist(args.match, [[\c\mterm://\(.\{-}\)//]])[2] or ""
            local exe = cmd:gsub("/", "\\")

            -- a saved Claude Code window is reopened by the session config instead
            if exe:match("\\claude[^\\]*$") then
                return
            end

            local job = vim.fn.executable(exe) == 1 and { exe } or cmd

            vim.fn.jobstart(job, { term = true, cwd = cwd ~= "" and vim.fn.expand(cwd) or nil })
        end,
    })
end

autocmd("LspAttach", {
    group = DefaultGroup,
    callback = function(e)
        vim.keymap.set("n", "gd", function()
            vim.lsp.buf.definition()
        end, { buffer = e.buf, desc = "LSP: go to definition" })
        vim.keymap.set("n", "K", function()
            vim.lsp.buf.hover()
        end, { buffer = e.buf, desc = "LSP: hover documentation" })
        vim.keymap.set("n", "<leader>vws", function()
            vim.lsp.buf.workspace_symbol()
        end, { buffer = e.buf, desc = "LSP: search workspace symbols" })
        vim.keymap.set("n", "<leader>vd", function()
            vim.diagnostic.open_float()
        end, { buffer = e.buf, desc = "LSP: show line diagnostics" })
        vim.keymap.set("n", "<leader>vca", function()
            vim.lsp.buf.code_action()
        end, { buffer = e.buf, desc = "LSP: code action" })
        vim.keymap.set("n", "<leader>vrr", function()
            vim.lsp.buf.references()
        end, { buffer = e.buf, desc = "LSP: list references" })
        vim.keymap.set("n", "<leader>vrn", function()
            vim.lsp.buf.rename()
        end, { buffer = e.buf, desc = "LSP: rename symbol" })
        vim.keymap.set("i", "<C-h>", function()
            vim.lsp.buf.signature_help()
        end, { buffer = e.buf, desc = "LSP: signature help" })
    end,
})

vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25
