local map = vim.keymap.set
vim.g.mapleader = " "
-- 保存：Ctrl+S
map({ "n", "i", "v" }, "<C-s>", "<cmd>w<cr>", { desc = "保存文件" })

-- 撤销 / 重做：Ctrl+Z / Ctrl+Y
map({ "n", "i", "v" }, "<C-z>", "<cmd>undo<cr>", { desc = "撤销" })
map({ "n", "i", "v" }, "<C-y>", "<cmd>redo<cr>", { desc = "重做" })

-- 注释切换：Ctrl+/
map("n", "<C-/>", "gcc", { remap = true, desc = "注释当前行" })
map("v", "<C-/>", "gc", { remap = true, desc = "注释选中行" })


-- 保存 / 退出 / 强制退出
map("n", "<leader>w", "<cmd>w<cr>", { desc = "保存" })
map("n", "<leader>q", "<cmd>q<cr>", { desc = "退出" })
map("n", "<leader>Q", "<cmd>qa!<cr>", { desc = "强制退出全部" })

-- 文件搜索
map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "查找文件" })
map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "全局搜索" })

-- 清除搜索高亮
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "清除搜索高亮" })

-- 窗口切换：Ctrl + hjkl
map("n", "<C-h>", "<C-w>h", { desc = "左侧窗口" })
map("n", "<C-j>", "<C-w>j", { desc = "下方窗口" })
map("n", "<C-k>", "<C-w>k", { desc = "上方窗口" })
map("n", "<C-l>", "<C-w>l", { desc = "右侧窗口" })

-- Buffer 切换：Shift+h / Shift+l
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "上一个文件" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "下一个文件" })

-- 关闭当前 Buffer
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "关闭当前文件" })

-- 可视模式下，将选中行向下移动（J 键）
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "移动选中行向下" })

-- 可视模式下，将选中行向上移动（K 键）
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "移动选中行向上" })

vim.keymap.set("i", "jj", "<Esc>", { desc = "退出插入模式" })