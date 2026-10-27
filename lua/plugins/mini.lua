-- ============================================================================
-- mini.nvim 全家桶：除 blink.cmp 外，所有体验层功能统一用 mini
-- 顺序很重要：icons 最先（bufferline 要用），clue 最后（要收录所有映射）
-- ============================================================================
vim.pack.add({ "https://github.com/echasnovski/mini.nvim" })

local map = vim.keymap.set

------------------------------------------------------------------------------
-- 1. 图标（并伪装成 nvim-web-devicons，供 bufferline 使用）
------------------------------------------------------------------------------
local icons = require("mini.icons")
icons.setup()
icons.mock_nvim_web_devicons()

------------------------------------------------------------------------------
-- 2. 编辑手感：文本对象 / 包围符 / 自动配对 / 括号跳转
------------------------------------------------------------------------------
require("mini.ai").setup({ n_lines = 500 })
require("mini.surround").setup()
require("mini.pairs").setup()

------------------------------------------------------------------------------
-- 3. 跳转：已换回 flash.nvim（见 plugins/flash.lua）
------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- 4. 选择器（替代 telescope.nvim）
------------------------------------------------------------------------------
local pick = require("mini.pick")
local extra = require("mini.extra")
pick.setup()
extra.setup()

map("n", "<leader>ff", function() pick.builtin.files() end, { desc = "查找文件" })
map("n", "<leader>fg", function() pick.builtin.grep_live() end, { desc = "全局搜索（实时）" })
map("n", "<leader>fb", function() pick.builtin.buffers() end, { desc = "切换 buffer" })
map("n", "<leader>fr", function() extra.pickers.oldfiles() end, { desc = "最近文件" })
map("n", "<leader>fh", function() pick.builtin.help() end, { desc = "帮助文档" })
map("n", "<leader>fk", function() extra.pickers.keymaps() end, { desc = "所有按键" })
map("n", "<leader>?", function() extra.pickers.keymaps() end, { desc = "查看可用按键" })
map("n", "<leader>gc", function() extra.pickers.git_commits() end, { desc = "提交历史" })
map("n", "<leader>gb", function() extra.pickers.git_branches() end, { desc = "切换分支" })

-- 诊断 / LSP 列表：已换回 trouble.nvim（见 plugins/trouble.lua）

------------------------------------------------------------------------------
-- 5. 文件管理（替代 oil.nvim + nvim-tree.lua）
------------------------------------------------------------------------------
require("mini.files").setup({
  windows = { preview = true },
  mappings = {
    -- l：打开文件并关闭浏览器（像 neo-tree/oil 的手感）
    -- L：打开文件但保留浏览器，方便连续打开多个
    go_in = "L",
    go_in_plus = "l",
  },
})

-- mini.files 的 buffer 是普通文本 buffer，<CR> 默认没映射（会插入空行）
-- 用 MiniFilesBufferCreate 补上回车打开/进入
vim.api.nvim_create_autocmd("User", {
  pattern = "MiniFilesBufferCreate",
  callback = function(args)
    local buf = args.data.buf_id
    local function set(lhs, fn, desc)
      vim.keymap.set("n", lhs, fn, { buffer = buf, nowait = true, desc = desc })
    end
    set("<CR>", function() require("mini.files").go_in({ close_on_file = true }) end, "打开/进入")
    -- 注意：不要映射 o！mini.files 靠 `o` 新建一行来创建文件/目录
    set("<Esc>", require("mini.files").close, "关闭浏览器")
    set("<C-v>", function()
      require("mini.files").go_in({ close_on_file = true, splits = { vertical = true } })
    end, "竖分屏打开")
  end,
})
map("n", "-", function()
  local files = require("mini.files")
  if files.close() == nil then files.open() end
end, { desc = "打开目录浏览器" })
map("n", "<leader>n", function()
  require("mini.files").open(vim.api.nvim_buf_get_name(0))
end, { desc = "在当前文件所在目录打开" })

------------------------------------------------------------------------------
-- 6. 状态栏（替代 lualine.nvim）
------------------------------------------------------------------------------
require("mini.statusline").setup({ use_icons = true })

------------------------------------------------------------------------------
-- 7. Git 行级改动：已换回 gitsigns.nvim（见 plugins/gitsigns.lua）
------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- 8. 会话（替代 persistence.nvim）
------------------------------------------------------------------------------
local sessions = require("mini.sessions")
sessions.setup({
  autoread = false,
  autowrite = true,
  file = "Session.vim", -- 每个项目一个本地会话
})
map("n", "<leader>ps", function() sessions.write() end, { desc = "保存会话" })
map("n", "<leader>pr", function() sessions.select() end, { desc = "选择会话" })
map("n", "<leader>pl", function()
  local latest = sessions.get_latest()
  if latest == nil then return vim.notify("没有可用会话", vim.log.levels.WARN) end
  sessions.read(latest)
end, { desc = "恢复上次会话" })

------------------------------------------------------------------------------
-- 9. TODO 高亮（替代 todo-comments.nvim）
------------------------------------------------------------------------------
local hipatterns = require("mini.hipatterns")
hipatterns.setup({
  highlighters = {
    fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
    hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
    todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
    note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },
    hex_color = hipatterns.gen_highlighter.hex_color(),
  },
})
map("n", "<leader>ft", function() require("mini.extra").pickers.hipatterns() end, {
  desc = "搜索 TODO/FIXME",
})

------------------------------------------------------------------------------
-- 10. 缩进竖线：已换回 indent-blankline（见 plugins/ibl.lua）
------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- 11. 按键提示（替代 which-key.nvim）—— 必须最后加载
------------------------------------------------------------------------------
local clue = require("mini.clue")
clue.setup({
  triggers = {
    { mode = { "n", "x" }, keys = "<Leader>" },
    { mode = "n", keys = "g" },
    { mode = "n", keys = "z" },
    { mode = "n", keys = "[" },
    { mode = "n", keys = "]" },
    { mode = "n", keys = "<C-w>" },
    { mode = "i", keys = "<C-x>" },
  },
  clues = {
    clue.gen_clues.builtin_completion(),
    clue.gen_clues.g(),
    clue.gen_clues.marks(),
    clue.gen_clues.registers(),
    clue.gen_clues.windows(),
    clue.gen_clues.square_brackets(),
    { mode = "n", keys = "<Leader>b", desc = "+buffer" },
    { mode = "n", keys = "<Leader>c", desc = "+code" },
    { mode = "n", keys = "<Leader>d", desc = "+debug / 诊断" },
    { mode = "n", keys = "<Leader>f", desc = "+find" },
    { mode = "n", keys = "<Leader>g", desc = "+git" },
    { mode = "n", keys = "<Leader>h", desc = "+hunk" },
    { mode = "n", keys = "<Leader>p", desc = "+session" },
  },
  window = { delay = 300, config = { border = "rounded" } },
})
