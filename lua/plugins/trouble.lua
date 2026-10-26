vim.pack.add({
  "https://github.com/nvim-tree/nvim-web-devicons",
  "https://github.com/folke/trouble.nvim",
})

require("trouble").setup({})

local map = vim.keymap.set

-- 诊断（常驻列表，实时刷新）
map("n", "<leader>d", "<cmd>Trouble diagnostics toggle<cr>", { desc = "整个工作区诊断" })
map("n", "<leader>D", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", { desc = "当前文件诊断" })
-- 符号 / 引用
map("n", "<leader>r", "<cmd>Trouble lsp_references toggle<cr>", { desc = "引用列表" })
map("n", "<leader>s", "<cmd>Trouble lsp_document_symbols toggle<cr>", { desc = "文档符号" })
map("n", "<leader>S", "<cmd>Trouble lsp_workspace_symbols toggle<cr>", { desc = "工作区符号" })
map("n", "<leader>l", "<cmd>Trouble loclist toggle<cr>", { desc = "位置列表" })
