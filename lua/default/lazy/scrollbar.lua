-- Scrollbar on the right edge of each window, replacing the % in the ruler (set.lua).
-- Marks are placed in proportion to the whole file: diagnostics in their
-- Diagnostic* colors (like the E/W signs), git changes in the gitsigns colors
-- (colors.lua), search matches, and the cursor.
return {
    "lewis6991/satellite.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
        handlers = {
            diagnostic = { enable = true },
            gitsigns = { enable = true },
            search = { enable = true },
            cursor = { enable = true },
            marks = { enable = false },
            quickfix = { enable = false },
        },
        excluded_filetypes = { "snacks_picker_list", "snacks_picker_input", "snacks_picker_preview" },
    },
}
