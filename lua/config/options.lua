-- 设置 Leader 键（必须放在插件加载和快捷键映射之前）
vim.g.mapleader = " "

-- 显示行号（混合模式：当前行绝对，其他行相对）
vim.opt.number = true
vim.opt.relativenumber = true

-- 缩进：使用空格代替 Tab，宽度为 4
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.smartindent = true

-- 搜索：忽略大小写，但如果包含大写字母则精确匹配
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true

-- 界面：高亮当前行，保持光标上下至少 10 行可见，关闭自动折行
vim.opt.cursorline = true
vim.opt.scrolloff = 10
vim.opt.wrap = false
vim.opt.signcolumn = "yes" -- 始终显示符号列，避免代码跳动

-- 剪贴板：不要 unnamedplus
-- 开了它之后 d / c / x / 可视模式 p 都会往系统剪贴板里写，刚复制的东西很容易被顶掉。
-- 现在只有显式 <leader>y / <leader>P 才碰系统剪贴板（见 config/keymaps.lua）
vim.opt.clipboard = ""

-- 其他实用设置
vim.opt.mouse = "a"           -- 启用鼠标
vim.opt.undofile = true       -- 持久化撤销历史
vim.opt.confirm = true        -- 关闭未保存文件前弹出确认