vim.pack.add({ "https://github.com/neovim/nvim-lspconfig" })

-- ============================================================================
-- 0. 全局默认
-- ============================================================================
-- 补全能力（snippet / 文档格式 / labelDetails / resolve）交给 blink.cmp 提供
-- 注意：init.lua 里 blink 要在 lspconfig 之前加载
vim.lsp.config("*", {
  -- 第二个参数 true = 先把 Neovim 自带的 capabilities 垫底（rename / codeAction / 诊断都得靠它），
  -- 再把 blink 的补全相关项盖上去
  capabilities = require("blink.cmp").get_lsp_capabilities(nil, true),
})

-- 诊断显示：按严重度排序 + 圆角浮窗，粘贴/插入时不刷新（否则很烦）
vim.diagnostic.config({
  severity_sort = true,
  virtual_text = { spacing = 2, prefix = "●" },
  float = { border = "rounded", source = true },
  update_in_insert = false,
})

-- ============================================================================
-- 1. 启用的服务端
-- mason 装二进制；nvim-lspconfig 提供默认 cmd / filetypes / root_markers
-- ============================================================================
vim.lsp.enable({
  "lua_ls", -- Lua
  "pyright", -- Python
  "c3_lsp", -- C3（c3lsp，根目录找 project.json / manifest.json / .git）
  "ts_ls", -- JavaScript / TypeScript / JSX / TSX
  "cssls", -- CSS / SCSS / Less
  "html", -- HTML
  "jsonls", -- JSON / JSONC
  "yamlls", -- YAML
  "bashls", -- sh / bash
  "marksman", -- Markdown
  "vimls", -- Vim script
  "clangd", -- C / C++
  "roslyn_ls", -- C#
  "jdtls", -- Java
})

-- ============================================================================
-- 2. 各服务端的个性配置
-- ============================================================================
local pkg = vim.fn.stdpath("data") .. "/mason/packages/"

-- Lua：认识 vim 全局，runtime 用 LuaJIT
vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      diagnostics = { globals = { "vim" } },
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
      hint = { enable = true },
    },
  },
})

-- Python：让 pyright 顺手读 .venv / 项目里的库，少点“类型未知”
vim.lsp.config("pyright", {
  settings = {
    python = {
      analysis = {
        typeCheckingMode = "basic",
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = "openFilesOnly",
      },
    },
  },
})

-- TypeScript / JavaScript
vim.lsp.config("ts_ls", {
  settings = {
    typescript = {
      updateImportsOnFileMove = { enabled = "always" },
      preferences = { importModuleSpecifier = "non-relative" },
      inlayHints = { parameterNames = { enabled = "literals" } },
    },
    javascript = {
      updateImportsOnFileMove = { enabled = "always" },
      preferences = { importModuleSpecifier = "non-relative" },
      inlayHints = { parameterNames = { enabled = "literals" } },
    },
  },
})

-- YAML：默认走 SchemaStore，写 k8s / GitHub Actions 时自带补全和校验
vim.lsp.config("yamlls", {
  settings = {
    yaml = {
      schemaStore = { enable = true, url = "" },
      validate = true,
      hover = true,
      completion = true,
      keyOrdering = false,
    },
  },
})

-- JSON：SchemaStore + 常见文件；关掉“注释/尾逗号”报错以外的东西
vim.lsp.config("jsonls", {
  settings = {
    json = {
      validate = { enable = true },
      schemas = {
        { fileMatch = { ".markdownlint-cli2.jsonc" }, url = "https://raw.githubusercontent.com/DavidAnson/markdownlint-cli2/main/schema/markdownlint-cli2-config-schema.json" },
      },
    },
  },
})

-- sh / bash：除了 .sh 也认 .bash / .command / .zsh
vim.lsp.config("bashls", {
  settings = {
    bashIde = {
      globPattern = "*@(.sh|.inc|.bash|.command|.zsh)",
      shellcheckArguments = { "-x" },
    },
  },
})

-- Markdown：marksman
vim.lsp.config("marksman", {
  root_markers = { ".marksman.toml", ".git" },
})

-- C / C++：clangd
--   --background-index  后台建索引（跳转跨文件才准）
--   --clang-tidy        用 .clang-tidy 规则（没有 compile_commands.json 时也会跑默认规则）
vim.lsp.config("clangd", {
  cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--completion-style=detailed",
    "--header-insertion=never",
    "--fallback-style=LLVM",
  },
})

-- C#：roslyn 语言服务器
vim.lsp.config("roslyn_ls", {
  settings = {
    ["csharp|background_analysis"] = {
      dotnet_analyzer_diagnostics_scope = "openFiles",
      dotnet_compiler_diagnostics_scope = "openFiles",
    },
    ["csharp|completion"] = {
      dotnet_show_completion_items_from_unimported_namespaces = true,
      dotnet_show_name_completion_suggestions = true,
    },
    ["csharp|inlay_hints"] = {
      csharp_enable_inlay_hints_for_implicit_variable = true,
      csharp_enable_inlay_hints_for_lambda_parameter = true,
      csharp_enable_inlay_hints_for_object_creation = true,
      csharp_enable_inlay_hints_for_types = true,
    },
    ["csharp|symbol_search"] = {
      dotnet_search_reference_assemblies = true,
    },
  },
})

-- Java：jdtls
-- 把 java-debug / java-test 的 jar 挂成 bundles，jdtls 才能执行 vscode.java.startDebugSession
-- （dap.lua 里的 Java 调试就是靠这个命令拿端口的）
local function jars_in(dir)
  return vim.fn.glob(dir .. "/*.jar", false, true)
end

vim.lsp.config("jdtls", {
  -- 注意：第一次启动时 mason 可能还没装完，bundles 会是空的，装好后重启即可
  init_options = {
    bundles = vim.list_extend(
      jars_in(pkg .. "java-debug-adapter/extension/server"),
      jars_in(pkg .. "java-test/extension/server")
    ),
    extendedClientCapabilities = {
      progressReportProvider = true,
      classFileContentsSupport = true,
    },
  },
})

-- ============================================================================
-- 3. 代码导航 / 文档（补全菜单是 blink.cmp 负责的，这里只补“选中后按 K 看介绍”这类）
-- ============================================================================
local map = vim.keymap.set
map("n", "K", vim.lsp.buf.hover, { desc = "悬停文档" })
map("n", "gd", vim.lsp.buf.definition, { desc = "跳转定义" })
map("n", "gr", vim.lsp.buf.references, { desc = "查找引用" })
map("n", "<leader>rn", vim.lsp.buf.rename, { desc = "重命名符号" })
map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "代码操作" })
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "显示当前行诊断" })
map("n", "<leader>ci", function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = 0 }), { bufnr = 0 })
end, { desc = "切换 inlay hints（类型/参数提示）" })
-- 跳声明/实现/符号列表不另外映射：0.11+ 自带 gD/gi 是内置动作，
-- 符号列表用 Trouble 的 <leader>s（文档）/ <leader>S（工作区），别重复造一份
