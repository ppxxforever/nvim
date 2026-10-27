vim.pack.add({ "https://github.com/mfussenegger/nvim-lint" })

local lint = require("lint")

-- 每个文件类型用哪个 linter（二进制由 mason 安装）
lint.linters_by_ft = {
  python = { "ruff" },
  lua = { "selene" },
  sh = { "shellcheck" },
  bash = { "shellcheck" },
  markdown = { "markdownlint-cli2" },
  yaml = { "yamllint" },
  -- 前端：eslint_d 自带 eslint，会先找项目里的 node_modules/.bin/eslint_d
  -- 项目没有 eslint 配置时它自己返回空结果，不会报错
  javascript = { "eslint_d" },
  javascriptreact = { "eslint_d" },
  typescript = { "eslint_d" },
  typescriptreact = { "eslint_d" },
  -- c / cpp：见下面的动态判断（clang-tidy）
  -- cs / java：没有开箱即用的 linter（checkstyle 需要自己配规则文件），靠 LSP 诊断
}

-- 从当前 buffer 所在目录往上找某个文件（不是 cwd，子目录里开文件也能找到项目根）
local function has_upward(names)
  local buf = vim.api.nvim_buf_get_name(0)
  local dir = buf ~= "" and vim.fn.fnamemodify(buf, ":p:h") or vim.fn.getcwd()
  while dir ~= "" do
    for _, name in ipairs(names) do
      if vim.fn.filereadable(dir .. "/" .. name) == 1 then return true end
    end
    local parent = vim.fn.fnamemodify(dir, ":h")
    if parent == dir then break end
    dir = parent
  end
  return false
end

-- clang-tidy 没有编译数据库时会满屏“找不到头文件”的假错误，只在项目给了配置时才跑
local function c_linters()
  local has_db = has_upward({ "compile_commands.json", "compile_flags.txt" })
  local has_conf = has_upward({ ".clang-tidy" })
  if not (has_db or has_conf) then return {} end

  -- clang-tidy 18+ 在没有任何 checks 配置时会直接报 “no checks enabled”，
  -- 所以没有项目的 .clang-tidy 时给一组默认规则；有的话尊重项目配置
  lint.linters.clangtidy.args = has_conf and { "--quiet" }
    or { "--quiet", "--checks=-*,clang-analyzer-*,bugprone-*,clang-diagnostic-*" }

  return { "clangtidy" }
end

-- 只在空闲/保存时跑，避免编辑时频繁刷新
vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave", "BufEnter" }, {
  callback = function()
    -- 只检查有 linter 注册的、且不是特殊 buffer 的
    if vim.bo.buftype ~= "" or vim.b.minifiles ~= nil then return end

    local ft = vim.bo.filetype
    if ft == "c" or ft == "cpp" then
      lint.linters_by_ft[ft] = c_linters()
    end

    lint.try_lint()
  end,
})

vim.keymap.set("n", "<leader>cl", function() lint.try_lint() end, { desc = "手动跑 linter" })

-- markdownlint-cli2 的规则文件放在 ~/.markdownlint-cli2.jsonc（它按“当前目录 → 祖先目录”查找）
-- 项目里想覆盖，就在项目根目录再放一个 .markdownlint-cli2.jsonc
