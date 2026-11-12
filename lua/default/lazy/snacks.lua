-- File explorer: a tree with git status, a preview beside it
-- when the editor is wide enough, and file operations
-- (a add, d delete, r rename, c copy, m move, y/p yank and paste, P toggle preview).

-- below this width the tree and the preview would both be too cramped
local MIN_COLUMNS_FOR_PREVIEW = 120

local function open_explorer()
    -- snacks keeps one explorer at a time and would just close an open one
    for _, existing in ipairs(Snacks.picker.get({ source = "explorer" })) do
        existing:close()
    end

    Snacks.picker.explorer({
        -- a function replaces the source's full-screen layout instead of merging into it
        layout = function()
            return {
                preset = "default",
                preview = vim.o.columns >= MIN_COLUMNS_FOR_PREVIEW,
            }
        end,
    })
end

return {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
        -- opening a directory (`nvim .`, `:e some/dir`) shows the explorer instead of netrw
        explorer = { replace_netrw = true },
        picker = {
            sources = {
                -- full screen like netrw, and gone once a file is opened (also for <C-p>)
                explorer = {
                    auto_close = true,
                    -- color folders by the git state of their contents, also when expanded
                    git_status_open = true,
                    jump = { close = true },
                    layout = {
                        preview = false,
                        fullscreen = true,
                        layout = {
                            box = "vertical",
                            border = "none",
                            { win = "input", height = 1, border = "bottom", title = "{title} {live} {flags}" },
                            { win = "list", border = "none" },
                        },
                    },
                },
            },
            icons = {
                -- plain characters, as this config has no Nerd Font icons
                files = {
                    dir = "▸ ",
                    dir_open = "▾ ",
                    file = "  ",
                },
                git = {
                    staged = "S",
                    added = "A",
                    deleted = "D",
                    ignored = "!",
                    modified = "M",
                    renamed = "R",
                    unmerged = "U",
                    untracked = "?",
                },
            },
        },
    },
    keys = {
        { "<C-p>", open_explorer, desc = "File explorer" },
    },
}
