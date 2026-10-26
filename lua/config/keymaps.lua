local map = vim.keymap.set

-- 保存 / 退出
map({ "n", "i", "v" }, "<C-s>", "<cmd>w<cr>", { desc = "保存文件" })
map("n", "<leader>w", "<cmd>w<cr>", { desc = "保存" })
map("n", "<leader>q", "<cmd>q<cr>", { desc = "退出" })
map("n", "<leader>Q", "<cmd>qa!<cr>", { desc = "强制退出全部" })

-- 撤销 / 重做
map({ "n", "i", "v" }, "<C-z>", "<cmd>undo<cr>", { desc = "撤销" })
map({ "n", "i", "v" }, "<C-y>", "<cmd>redo<cr>", { desc = "重做" })

-- 注释切换（依赖 0.10+ 内置 gc）
map("n", "<C-/>", "gcc", { remap = true, desc = "注释当前行" })
map("v", "<C-/>", "gc", { remap = true, desc = "注释选中行" })

-- 退出插入模式（中文输入法兼容）
map("i", "jj", "<Esc>", { desc = "退出插入模式" })

-- 清除搜索高亮
map("n", "jk", "<cmd>nohlsearch<cr>", { desc = "清除搜索高亮" })

-- 窗口切换：Ctrl + hjkl
map("n", "<C-h>", "<C-w>h", { desc = "左侧窗口" })
map("n", "<C-j>", "<C-w>j", { desc = "下方窗口" })
map("n", "<C-k>", "<C-w>k", { desc = "上方窗口" })
map("n", "<C-l>", "<C-w>l", { desc = "右侧窗口" })

-- Buffer 切换
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "上一个文件" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "下一个文件" })
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "关闭当前文件" })

-- 系统剪贴板：只走显式按键（clipboard 不开 unnamedplus）
-- 好处：dd / cc / 可视模式 p 只动无名寄存器，不会把刚复制的内容顶掉
map({ "n", "x" }, "<leader>y", '"+y', { desc = "复制到系统剪贴板" })
map("n", "<leader>Y", '"+yy', { desc = "整行复制到系统剪贴板" })
map({ "n", "x" }, "<leader>P", '"+P', { desc = "从系统剪贴板粘贴" })

-- 删除/修改一律丢进黑洞寄存器 _，连无名寄存器也不动
-- 这样 dd / cc / x / D 之后，p 里还是你上一次复制的内容
-- 显式写寄存器时照常生效（"ad 进 a 寄存器，"+d 进系统剪贴板）
local function blackhole(key)
  return function()
    -- v:register == '"' 表示这次没有 "x 前缀
    return vim.v.register == '"' and '"_' .. key or key
  end
end
-- 注：故意没映射 s —— 它是 mini.surround 的 sa/sd/sr 前缀，映射后每次都要等 timeoutlen
for _, key in ipairs({ "d", "D", "c", "C", "x", "X", "S" }) do
  map({ "n", "x" }, key, blackhole(key), { expr = true, desc = "删除/修改不写寄存器" })
end

-- 可视模式：整块上下移动
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "移动选中行向下" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "移动选中行向上" })
