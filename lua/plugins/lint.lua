vim.pack.add({ "https://github.com/mfussenegger/nvim-lint" })

local lint = require("lint")

-- 每个文件类型用哪个 linter（二进制由 mason 安装）
lint.linters_by_ft = {
  python = { "ruff" },
  lua = { "selene" },
  sh = { "shellcheck" },
  markdown = { "markdownlint-cli2" },
}

-- 只在空闲/保存时跑，避免编辑时频繁刷新
vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave", "BufEnter" }, {
  callback = function()
    -- 只检查有 linter 注册的、且不是特殊 buffer 的
    if vim.bo.buftype ~= "" or vim.b.minifiles ~= nil then return end
    lint.try_lint()
  end,
})

vim.keymap.set("n", "<leader>cl", function() lint.try_lint() end, { desc = "手动跑 linter" })

-- markdownlint-cli2 的规则文件放在 ~/.markdownlint-cli2.jsonc（它按“当前目录 → 祖先目录”查找）
-- 项目里想覆盖，就在项目根目录再放一个 .markdownlint-cli2.jsonc
