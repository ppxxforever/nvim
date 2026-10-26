-- 图标由 mini.icons 的 mock 提供，无需 nvim-web-devicons
vim.opt.termguicolors = true
vim.pack.add({ "https://github.com/akinsho/bufferline.nvim" })
require("bufferline").setup({})

local map = vim.keymap.set
map("n", "<leader>bn", "<cmd>BufferLineCycleNext<cr>", { desc = "下一个标签" })
map("n", "<leader>bp", "<cmd>BufferLineCyclePrev<cr>", { desc = "上一个标签" })
-- 关闭标签统一用 <leader>bd（定义在 config/keymaps.lua）
