vim.pack.add({ "https://github.com/neovim/nvim-lspconfig" })
vim.lsp.enable({
  "lua_ls",
  "pyright",
  "c3_lsp", -- c3lsp，由 mason 安装；根目录找 project.json / manifest.json / .git
})

-- 代码导航 / 文档（补全菜单是 blink.cmp 负责的，这里只补“选中后按 K 看介绍”这类）
local map = vim.keymap.set
map("n", "K", vim.lsp.buf.hover, { desc = "悬停文档" })
map("n", "gd", vim.lsp.buf.definition, { desc = "跳转定义" })
map("n", "gr", vim.lsp.buf.references, { desc = "查找引用" })
map("n", "<leader>rn", vim.lsp.buf.rename, { desc = "重命名符号" })
map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "代码操作" })