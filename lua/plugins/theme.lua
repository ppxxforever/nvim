-- ============================================================================
-- 配色：nightfox.nvim（变体 carbonfox + 透明背景）
-- 必须在其它 UI 插件（bufferline / statusline / trouble 等）之前加载，
-- 这样它们初始化时读到的就是 nightfox 的 highlight 组。
-- 换变体只需改最后一行：:colorscheme nightfox|dayfox|dawnfox|duskfox|nordfox|terafox|carbonfox
-- ============================================================================
vim.pack.add({ "https://github.com/EdenEast/nightfox.nvim" })

require("nightfox").setup({
  options = {
    transparent = true, -- 透明背景：让终端背景/壁纸透出来
    terminal_colors = true, -- :terminal 也用主题配色
    dim_inactive = false, -- true = 非活动窗口变暗
    module_default = true, -- 启用 nightfox 内置的各插件配色（blink/bufferline/mini/trouble...）
    styles = {
      -- 想给代码加风格化就把 "NONE" 换成 "bold" / "italic"
      comments = "NONE",
      conditionals = "NONE",
      constants = "NONE",
      functions = "NONE",
      keywords = "NONE",
      numbers = "NONE",
      operators = "NONE",
      preprocs = "NONE",
      strings = "NONE",
      types = "NONE",
      variables = "NONE",
    },
    inverse = {
      match_paren = false,
      visual = false,
      search = false,
    },
  },
})

vim.cmd.colorscheme("carbonfox")
