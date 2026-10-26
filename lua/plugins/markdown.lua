-- ============================================================================
-- Markdown 写作环境
--   · render-markdown.nvim —— buf 内实时渲染（标题/列表/代码块/表格/复选框）
--   · 配色：从 nightfox 的 carbonfox 调色板取色，混出低饱和的卡片底色
--   · 折行、2 空格缩进（对齐 prettier 的 markdown 默认值）
--   · 依赖 treesitter 的 markdown / markdown_inline 解析器（见 plugins/treesitter.lua）
--   · lint 由 markdownlint-cli2 提供（见 plugins/lint.lua）
--   · 格式化由 prettier 提供（见 plugins/conform.lua）
-- ============================================================================
vim.pack.add({ "https://github.com/MeanderingProgrammer/render-markdown.nvim" })

require("render-markdown").setup({
  file_types = { "markdown", "markdown.mdx" },

  heading = {
    enabled = true,
    sign = false, -- 符号列留给诊断，不放标题级别
    position = "inline", -- 图标内联在文字前，各级标题左边缘对齐
    width = "full", -- 整行色块（卡片风）
    left_pad = 1,
    right_pad = 1,
    border = false,
    -- 不要标题前的图标：留空字符串，render-markdown 会只隐藏 '#' 不加任何符号
    icons = { "", "", "", "", "", "" },
  },

  code = {
    enabled = true,
    sign = false,
    style = "full",
    border = "thin", -- 上下各一条线 + 语言名，不封左右（render-markdown 不支持竖边）
    language = true,
    language_icon = false, -- 只要语言名，不要图标
    language_left = " ",
    language_right = " ",
    language_info = false,
    language_border = "─", -- 顶线用细线而不是 █ 实心块
    above = "─",
    below = "─",
    left_pad = 1,
    right_pad = 1,
    width = "full",
    inline = true,
    inline_pad = 1,
  },

  bullet = {
    enabled = true,
    icons = { "●", "○", "◆", "◇" },
    left_pad = 1,
    right_pad = 0,
  },

  checkbox = {
    enabled = true,
    unchecked = { icon = "󰄱 " },
    checked = { icon = "󰱒 " },
  },

  -- repeat_linebreak：折行后仍然画竖线，长引用读起来才连得住
  quote = { enabled = true, icon = "▎", repeat_linebreak = true },
  dash = { enabled = true, icon = "─" },

  pipe_table = {
    enabled = true,
    preset = "round", -- 圆角框
    cell = "padded",
    padding = 1,
  },

  link = {
    enabled = true,
    hyperlink = "󰌹 ",
    image = "󰥶 ",
    email = "󰀓 ",
  },

  -- 列表缩进竖线交给 ibl 会打架（ibl 画 │、这里画 ▎），markdown 里两边都关掉更干净
  indent = { enabled = false },

  -- 光标所在行恢复成原始 markdown，方便直接改源码
  anti_conceal = { enabled = true },
})

------------------------------------------------------------------------------
-- 配色：卡片底色 / 标题前景 / 代码块 / 表格等都从 carbonfox 调色板推导
------------------------------------------------------------------------------
local function setup_markdown_colors()
  local ok, pal = pcall(function() return require("nightfox.palette").load("carbonfox") end)
  if not ok or not pal then return end

  -- 把 color 以 factor 比例混到 base 上，得到低饱和的深色底
  local function mix(color, factor, base)
    local function rgb(h)
      return tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16)
    end
    local br, bg, bb = rgb(base)
    local cr, cg, cb = rgb(color)
    local function f(a, b) return math.floor(a + (b - a) * factor + 0.5) end
    return string.format("#%02x%02x%02x", f(br, cr), f(bg, cg), f(bb, cb))
  end

  local base = pal.bg1 -- 卡片底色以 bg1 为基准（整个背景是透明的）
  local hl = vim.api.nvim_set_hl

  -- 六级标题：前景亮色 + 同色系的暗底，逐级减弱
  local headings = {
    { pal.blue, 0.20, true },
    { pal.cyan, 0.17, true },
    { pal.green, 0.15, true },
    { pal.magenta, 0.14, true },
    { pal.pink, 0.12, true },
    { pal.fg2, 0.0, false }, -- H6 收尾用中性灰，不再抢眼
  }
  for i, spec in ipairs(headings) do
    local color, strength, bold = spec[1], spec[2], spec[3]
    local fg = type(color) == "table" and color.bright or color
    hl(0, "RenderMarkdownH" .. i, { fg = fg, bold = bold })
    hl(0, "RenderMarkdownH" .. i .. "Bg", {
      bg = strength > 0 and mix(color.base, strength, base) or pal.bg2,
    })
  end

  -- 代码块：比标题卡更中性一点的深底 + 蓝色顶线
  local code_bg = mix(pal.blue.base, 0.07, pal.bg1)
  hl(0, "RenderMarkdownCode", { bg = code_bg })
  -- 顶/底线用中性灰；语言名做成灰底标签（底线的字色 = 本组的 bg）
  hl(0, "RenderMarkdownCodeBorder", { fg = pal.bg0, bg = pal.bg4 })
  hl(0, "RenderMarkdownCodeInline", { bg = mix(pal.blue.base, 0.13, base), fg = pal.fg0 })
  hl(0, "RenderMarkdownCodeFallback", { fg = pal.fg2 })
  hl(0, "RenderMarkdownCodeInfo", { fg = pal.comment })

  -- 列表 / 引用 / 分割线 / 链接
  hl(0, "RenderMarkdownBullet", { fg = pal.cyan.dim })
  hl(0, "RenderMarkdownChecked", { fg = pal.green.base })
  hl(0, "RenderMarkdownUnchecked", { fg = pal.fg3 })
  hl(0, "RenderMarkdownTodo", { fg = pal.yellow.base })
  local quotes = { pal.blue.dim, pal.cyan.dim, pal.green.dim, pal.magenta.dim, pal.pink.dim, pal.comment }
  for i, c in ipairs(quotes) do
    hl(0, "RenderMarkdownQuote" .. i, { fg = c })
  end
  hl(0, "RenderMarkdownDash", { fg = pal.bg4 })
  hl(0, "RenderMarkdownLink", { fg = pal.blue.bright })
  hl(0, "RenderMarkdownLinkTitle", { fg = pal.comment })

  -- 表格：圆角框线用暗色，表头亮一点
  hl(0, "RenderMarkdownTableHead", { fg = pal.fg1, bold = true })
  hl(0, "RenderMarkdownTableRow", { fg = pal.bg4 })
end

setup_markdown_colors()
vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("MarkdownColors", { clear = true }),
  callback = setup_markdown_colors,
})

------------------------------------------------------------------------------
-- Markdown buffer 的编辑选项
------------------------------------------------------------------------------
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("MarkdownWriting", { clear = true }),
  pattern = { "markdown", "markdown.mdx" },
  callback = function()
    local opt = vim.opt_local
    opt.wrap = true -- 全局 wrap 是关的，散文需要折行
    opt.linebreak = true -- 折行只在空格处断开，不切断单词
    opt.breakindent = true
    opt.breakindentopt = "shift:2" -- 折行的续行缩进 2 格，列表/引用读起来连贯
    opt.expandtab = true
    opt.tabstop = 2 -- 与 prettier / markdownlint 的 2 空格缩进一致
    opt.shiftwidth = 2
    opt.softtabstop = 2
    -- conceallevel 交给 render-markdown 的 win_options 自己管，别在这里覆盖
  end,
})

------------------------------------------------------------------------------
-- 快捷键
------------------------------------------------------------------------------
vim.keymap.set("n", "<leader>cm", "<cmd>RenderMarkdown toggle<cr>", { desc = "切换 Markdown 渲染" })
