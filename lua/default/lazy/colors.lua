return {
    {
        "sainnhe/gruvbox-material",
        priority = 1000,
        lazy = false,
        config = function()
            vim.g.gruvbox_material_background = "medium"
            vim.g.gruvbox_material_transparent_background = 2
            vim.g.gruvbox_material_enable_italic = 0

            -- reapplied on every colorscheme load, since changing 'background'
            -- (light/dark switch) reloads the scheme and wipes these overrides
            vim.api.nvim_create_autocmd("ColorScheme", {
                pattern = "gruvbox-material",
                callback = function()
                    for _, group in ipairs({
                        "FloatBorder",
                        "StatusLine",
                        "StatusLineNC",
                    }) do
                        vim.api.nvim_set_hl(0, group, { link = "Normal" })
                    end

                    -- thin line between windows, dimmed like the line numbers
                    vim.api.nvim_set_hl(0, "WinSeparator", { link = "LineNr" })

                    -- Snacks explorer: directories in plain text like files, and the
                    -- filename colored by git state: staged green, unstaged yellow,
                    -- untracked grey (NonText, the Snacks default)
                    vim.api.nvim_set_hl(0, "SnacksPickerDirectory", { link = "Normal" })
                    vim.api.nvim_set_hl(0, "SnacksPickerGitStatusStaged", { link = "Green" })
                    for _, group in ipairs({
                        "SnacksPickerGitStatusModified",
                        "SnacksPickerGitStatusAdded",
                        "SnacksPickerGitStatusRenamed",
                        "SnacksPickerGitStatusCopied",
                    }) do
                        vim.api.nvim_set_hl(0, group, { link = "Yellow" })
                    end
                end,
            })

            vim.cmd.colorscheme("gruvbox-material")
        end,
    },
}
