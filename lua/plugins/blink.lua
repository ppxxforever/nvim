vim.pack.add({
  "https://github.com/saghen/blink.lib",
  "https://github.com/saghen/blink.cmp",
})
local cmp = require("blink.cmp")
cmp.build():pwait()

cmp.setup({
  -- 快捷键：默认预设是 Vim 风格（C-y 接受），Tab 用 VSCode 那种“上下选”
  keymap = {
    preset = "default",
    ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
    ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
    ["<C-space>"] = { "show", "show_documentation", "hide_documentation" }, -- 手动触发 / 切换文档
    ["<C-k>"] = { "show_signature", "hide_signature", "fallback" }, -- 函数签名参数提示
    ["<C-b>"] = { "scroll_documentation_up", "fallback" },
    ["<C-f>"] = { "scroll_documentation_down", "fallback" },
  },

  appearance = {
    nerd_font_variant = "mono",
  },

  completion = {
    -- ★ 关键：选中补全项时自动弹出文档窗口（函数签名 + 注释说明 + 变量类型）
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 200,
      update_delay_ms = 50,
      treesitter_highlighting = true, -- 文档里的代码块按语法高亮
      window = {
        border = "rounded",
        max_width = 80,
        max_height = 20,
        scrollbar = true,
      },
    },

    menu = {
      border = "rounded",
      draw = {
        -- 每行：图标 | 名字 + 括号里的细节 | 右侧签名/类型
        columns = {
          { "kind_icon" },
          { "label", "label_description", gap = 1 },
          { "detail" },
        },
        components = {
          -- LSP 的 detail（如 `fn void foo(int a)` / `int`），VSCode 列表右侧那一列
          detail = {
            width = { max = 40 },
            text = function(ctx)
              local detail = ctx.item.detail or ""
              return detail:gsub("\n", " "):gsub("%s+$", "")
            end,
            highlight = "BlinkCmpLabelDescription",
          },
        },
      },
    },

    -- 行内灰色预览（像 VSCode 的 ghost text）
    ghost_text = { enabled = true },
    accept = { auto_brackets = { enabled = true } },
    list = { selection = { preselect = false, auto_insert = true } },
  },

  -- 括号里自动弹出参数提示
  signature = {
    enabled = true,
    window = { border = "rounded", show_documentation = true },
  },

  sources = { default = { "lsp", "path", "snippets", "buffer" } },
  fuzzy = { implementation = "prefer_rust_with_warning" },
})
