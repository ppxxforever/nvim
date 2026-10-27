-- mini.nvim 负责基础体验；下列 4 个非 mini 插件是功能优先的选择
require("config.env") -- 运行时 PATH（java / dotnet），必须在插件之前
require("config.options")
require("config.keymaps")

require("plugins.theme") -- 配色：nightfox（carbonfox + 透明），要在 UI 插件之前

require("plugins.mini") -- 必须先加载：提供 mini.icons 供 bufferline 使用

require("plugins.flash") -- 跳转：比 mini.jump2d 强（treesitter/多窗口/搜索联动）
require("plugins.ibl") -- 缩进竖线：mini 没有等价物
require("plugins.trouble") -- 诊断/引用常驻列表：mini.pick 只能一次性选择
require("plugins.gitsigns") -- blame + hunk 暂存：mini.diff 没有行内 blame

require("plugins.bufferline") -- mini 没有 buffer 标签栏
require("plugins.terminal") -- 终端：<leader>tt 底部 / <leader>tf 浮动
require("plugins.treesitter")
require("plugins.blink") -- 补全：mini.completion 太弱（要在 lspconfig 之前，好把 capabilities 交给 vim.lsp.config）
require("plugins.mason")
require("plugins.lspconfig")
require("plugins.conform") -- 格式化：stylua / ruff_format / prettier
require("plugins.lint") -- linter：ruff / selene / shellcheck / markdownlint-cli2
require("plugins.markdown") -- markdown 写作：render-markdown 实时渲染
require("plugins.dap") -- 调试：nvim-dap + dap-ui
require("plugins.neogit")
