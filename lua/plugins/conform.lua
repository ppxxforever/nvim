vim.pack.add({ "https://github.com/stevearc/conform.nvim" })

require("conform").setup({
  formatters_by_ft = {
    lua = { "stylua" },
    python = { "ruff_organize_imports", "ruff_format" },
    -- 前端
    javascript = { "prettier" },
    javascriptreact = { "prettier" },
    typescript = { "prettier" },
    typescriptreact = { "prettier" },
    css = { "prettier" },
    scss = { "prettier" },
    less = { "prettier" },
    html = { "prettier" },
    json = { "prettier" },
    jsonc = { "prettier" },
    markdown = { "prettier" },
    -- 配置 / 脚本
    yaml = { "yamlfmt" },
    sh = { "shfmt" },
    bash = { "shfmt" },
    -- 编译型
    c = { "clang-format" },
    cpp = { "clang-format" },
    cs = { "csharpier" },
    java = { "google-java-format" },
    -- C3：c3c 没有 fmt 子命令，只能靠 c3lsp 的 LSP 格式化（lsp_format 回退）
    -- vim：没有靠谱的格式化器，不动
  },

  formatters = {
    ["clang-format"] = { prepend_args = { "-style=file", "-fallback-style=LLVM" } },
    -- Google 官方风格是 2 空格；--aosp 是 4 空格，和全局 tabstop=4 更一致
    ["google-java-format"] = { prepend_args = { "--aosp" } },
    -- 默认会把折行拼成一行，写 markdown 里的 yaml 示例时很难受
    yamlfmt = { prepend_args = { "-formatter", "retain_line_breaks=true" } },
  },

  format_on_save = { timeout_ms = 3000, lsp_format = "fallback" },
})

vim.keymap.set({ "n", "v" }, "<leader>cf", function()
  require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "格式化" })
