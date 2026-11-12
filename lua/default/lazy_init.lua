local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    spec = "default.lazy",
    change_detection = { notify = false },
    -- no plugin here needs luarocks; plenary ships a rockspec, so lazy would try
    -- (and fail on Windows without luarocks) to build it
    rocks = { enabled = false },
})
