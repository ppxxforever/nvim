vim.pack.add({ "https://github.com/mason-org/mason.nvim" })
require("mason").setup()

-- ============================================================================
-- 自动补齐：mason 自带 registry API，不需要额外插件
-- 每次启动只做“缺什么装什么”，装完就可以直接用（LSP 下次开文件生效）
-- ============================================================================
local ensure_installed = {
  -- LSP 服务端
  "lua-language-server", -- lua_ls
  "pyright", -- Python
  "c3-lsp", -- C3
  "typescript-language-server", -- ts_ls：JS / TS
  "yaml-language-server", -- yamlls
  "json-lsp", -- jsonls
  "css-lsp", -- cssls
  "html-lsp", -- html
  "bash-language-server", -- bashls
  "marksman", -- markdown（跳转 / 补全 / 反向引用）
  "vim-language-server", -- vimls
  "clangd", -- C / C++
  "roslyn-language-server", -- C#（需要 dotnet）
  "jdtls", -- Java（需要 java）

  -- 格式化（conform）
  "stylua",
  "ruff",
  "prettier",
  "shfmt",
  "yamlfmt",
  "clang-format",
  "csharpier", -- 需要 dotnet
  "google-java-format", -- 需要 java

  -- Lint（nvim-lint）
  "selene",
  "shellcheck",
  "markdownlint-cli2",
  "eslint_d",
  "yamllint",
  "clang-tidy",

  -- 调试（nvim-dap）
  "debugpy", -- Python
  "codelldb", -- C / C++
  "netcoredbg", -- C#
  "js-debug-adapter", -- JS / TS
  "java-debug-adapter", -- Java（配合 jdtls）
  "java-test", -- Java 测试运行器（java-debug 的 bundles 依赖）
}

local registry = require("mason-registry")

-- 临时开关：`NVIM_NO_MASON_INSTALL=1 nvim` 只检查不下载（离线 / 不想现在下的时候用）
local auto_install = vim.env.NVIM_NO_MASON_INSTALL ~= "1"

registry.refresh(function()
  for _, name in ipairs(ensure_installed) do
    local ok, pkg = pcall(registry.get_package, name)
    if not ok then
      vim.notify(("[mason] 注册表里没有 %s（名字可能改了）"):format(name), vim.log.levels.WARN)
    elseif not pkg:is_installed() then
      if auto_install then
        pkg:install({}, function(success, err)
          if not success then
            vim.notify(("[mason] %s 安装失败：%s"):format(name, err), vim.log.levels.ERROR)
          end
        end)
      end
    end
  end
end)

vim.keymap.set("n", "<leader>cM", "<cmd>Mason<cr>", { desc = "mason 包管理" })
