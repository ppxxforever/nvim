vim.pack.add({ "https://github.com/lukas-reineke/indent-blankline.nvim" })

require("ibl").setup({
  indent = { char = "│" },
  scope = { show_start = false, show_end = false, enabled = true },
  exclude = {
    -- markdown 不画缩进竖线：散文里只会变成噪音，且会和 render-markdown 打架
    filetypes = { "help", "dashboard", "neogitstatus", "Trouble", "NvimTree", "oil", "minifiles", "minifiles-help", "markdown" },
  },
})
