vim.pack.add({
  "https://github.com/mfussenegger/nvim-dap",
  "https://github.com/nvim-neotest/nvim-nio",
  "https://github.com/rcarriga/nvim-dap-ui",
})

local dap = require("dap")
local dapui = require("dapui")

------------------------------------------------------------------------------
-- 界面
------------------------------------------------------------------------------
dapui.setup({
  icons = { expanded = "", collapsed = "", current_frame = "" },
  layouts = {
    {
      elements = {
        { id = "scopes", size = 0.30 },
        { id = "breakpoints", size = 0.20 },
        { id = "stacks", size = 0.25 },
        { id = "watches", size = 0.25 },
      },
      size = 40,
      position = "left",
    },
    {
      elements = { { id = "repl", size = 0.5 }, { id = "console", size = 0.5 } },
      size = 12,
      position = "bottom",
    },
  },
})

-- 进入/退出调试时自动开关 UI
dap.listeners.after.event_initialized["dapui_config"] = dapui.open
dap.listeners.before.event_terminated["dapui_config"] = dapui.close
dap.listeners.before.event_exited["dapui_config"] = dapui.close

------------------------------------------------------------------------------
-- 符号
------------------------------------------------------------------------------
vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError", linehl = "", numhl = "" })
vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticWarn", linehl = "Visual", numhl = "" })
vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DiagnosticInfo" })
vim.fn.sign_define("DapLogPoint", { text = "◆", texthl = "DiagnosticInfo" })

------------------------------------------------------------------------------
-- mason 包里的路径（不同版本的解压结构不一样，按候选顺序找）
------------------------------------------------------------------------------
local pkg_dir = vim.fn.stdpath("data") .. "/mason/packages/"

local function mason_bin(package, candidates)
  for _, rel in ipairs(candidates) do
    local p = pkg_dir .. package .. "/" .. rel
    if vim.fn.executable(p) == 1 then return p end
  end
  -- 兜底：mason/bin 里的同名 wrapper（mason 会把可执行文件软链到那里）
  local name = vim.fn.fnamemodify(candidates[1], ":t")
  local wrapper = vim.fn.exepath(name)
  if wrapper ~= "" then return wrapper end
end

local function mason_file(package, rel)
  local p = pkg_dir .. package .. "/" .. rel
  return vim.uv.fs_stat(p) and p or nil
end

-- 调试器对应的 mason 包没装时，提前说一声（而不是等 F5 报“没有配置”）
local function warn_missing(package, adapter)
  if require("mason-registry").is_installed(package) then return end
  vim.schedule(function()
    vim.notify(
      ("[dap] %s 调试不可用：mason 包 %s 未安装。\n先 :MasonInstall %s（或在 mason.lua 的清单里等它自动装）"):format(
        adapter, package, package),
      vim.log.levels.WARN
    )
  end)
end

------------------------------------------------------------------------------
-- Python
-- 优先用 uv 建的独立 venv（早期 mason 的 debugpy 因缺 python3-venv 装不上）
-- 现在 mason 的 debugpy 也能用了，所以路径不存在时自动回退到 mason 的 debugpy-adapter
------------------------------------------------------------------------------
local dap_python = vim.fn.expand("~/.local/share/nvim/debugpy-venv/bin/python")

dap.adapters.python = function(cb, config)
  if config.request == "attach" then
    cb({
      type = "server",
      port = config.port or 5678,
      host = config.host or "127.0.0.1",
    })
  else
    if vim.fn.executable(dap_python) == 1 then
      cb({
        type = "executable",
        command = dap_python,
        args = { "-m", "debugpy.adapter" },
      })
    else
      -- 回退：如果以后 mason 装成功了，就用它的 wrapper
      cb({
        type = "executable",
        command = vim.fn.exepath("debugpy-adapter"),
        args = {},
      })
    end
  end
end

dap.configurations.python = {
  {
    type = "python",
    request = "launch",
    name = "启动当前文件",
    program = "${file}",
    pythonPath = function()
      local venv = vim.fn.getcwd() .. "/.venv/bin/python"
      if vim.fn.executable(venv) == 1 then return venv end
      return vim.fn.exepath("python3")
    end,
    console = "integratedTerminal",
  },
  {
    type = "python",
    request = "launch",
    name = "启动当前文件（带参数…）",
    program = "${file}",
    args = function()
      return vim.split(vim.fn.input("参数: "), " ", { trimempty = true })
    end,
  },
  {
    type = "python",
    request = "attach",
    name = "附加到远程 (5678)",
    connect = { host = "127.0.0.1", port = 5678 },
    pathMappings = {
      { localRoot = "${workspaceFolder}", remoteRoot = "." },
    },
  },
}

------------------------------------------------------------------------------
-- C / C++：codelldb（LLDB 内核，比 gdb 那套适配器稳定）
------------------------------------------------------------------------------
local codelldb = mason_bin("codelldb", {
  "extension/adapter/codelldb",
  "extension/lldb/adapter/codelldb",
})

if codelldb then
  dap.adapters.codelldb = {
    type = "server",
    port = "${port}",
    executable = { command = codelldb, args = { "--port", "${port}" } },
  }

  -- 编译当前文件（单文件调试够用了；多文件项目请用 CMake/Make 的 compile_commands.json）
  local function build_current(ft)
    local src = vim.api.nvim_buf_get_name(0)
    local out = vim.fs.joinpath(vim.fn.getcwd(), "build", vim.fn.fnamemodify(src, ":t:r"))
    vim.fn.mkdir(vim.fs.dirname(out), "p")
    local cc = (ft == "cpp") and "g++" or "gcc"
    local result = vim.system({ cc, "-g", "-O0", "-Wall", "-o", out, src }, { text = true }):wait()
    if result.code ~= 0 then
      vim.notify("编译失败：\n" .. (result.stderr or ""), vim.log.levels.ERROR)
      return nil
    end
    return out
  end

  dap.configurations.c = {
    {
      name = "编译并启动当前文件",
      type = "codelldb",
      request = "launch",
      program = function() return build_current("c") end,
      cwd = "${workspaceFolder}",
      stopOnEntry = false,
    },
    {
      name = "启动（选可执行文件）",
      type = "codelldb",
      request = "launch",
      program = function()
        return vim.fn.input("可执行文件: ", vim.fn.getcwd() .. "/build/", "file")
      end,
      cwd = "${workspaceFolder}",
      stopOnEntry = false,
    },
    {
      name = "附加到进程",
      type = "codelldb",
      request = "attach",
      pid = require("dap.utils").pick_process,
      cwd = "${workspaceFolder}",
    },
  }

  dap.configurations.cpp = {
    {
      name = "编译并启动当前文件",
      type = "codelldb",
      request = "launch",
      program = function() return build_current("cpp") end,
      cwd = "${workspaceFolder}",
      stopOnEntry = false,
    },
    dap.configurations.c[2],
    dap.configurations.c[3],
  }
else
  warn_missing("codelldb", "C / C++")
end

------------------------------------------------------------------------------
-- C#：netcoredbg（CoreCLR 调试器）
------------------------------------------------------------------------------
local netcoredbg = mason_bin("netcoredbg", { "netcoredbg", "bin/netcoredbg" })

if netcoredbg then
  dap.adapters.coreclr = {
    type = "executable",
    command = netcoredbg,
    args = { "--interpreter=vscode" },
  }

  dap.configurations.cs = {
    {
      name = "启动 .NET 程序（选 dll）",
      type = "coreclr",
      request = "launch",
      program = function()
        return vim.fn.input("dll 路径: ", vim.fn.getcwd() .. "/bin/Debug/", "file")
      end,
      cwd = "${workspaceFolder}",
    },
    {
      name = "附加到进程",
      type = "coreclr",
      request = "attach",
      processId = require("dap.utils").pick_process,
    },
  }
else
  warn_missing("netcoredbg", "C#")
end

------------------------------------------------------------------------------
-- JavaScript / TypeScript：vscode-js-debug（需要 node）
------------------------------------------------------------------------------
local js_debug_server = mason_file("js-debug-adapter", "js-debug/src/dapDebugServer.js")

if js_debug_server and vim.fn.executable("node") == 1 then
  dap.adapters["pwa-node"] = {
    type = "server",
    host = "127.0.0.1",
    port = "${port}",
    executable = { command = "node", args = { js_debug_server, "${port}" } },
  }

  local js_configs = {
    {
      name = "启动当前文件",
      type = "pwa-node",
      request = "launch",
      program = "${file}",
      cwd = "${workspaceFolder}",
      sourceMaps = true,
      console = "integratedTerminal",
      skipFiles = { "<node_internals>/**" },
    },
    {
      name = "启动并直接跑 .ts（Node 类型剥离）",
      type = "pwa-node",
      request = "launch",
      runtimeExecutable = "node",
      runtimeArgs = { "--experimental-strip-types" }, -- Node 22+ 可以直接跑 .ts
      program = "${file}",
      cwd = "${workspaceFolder}",
      console = "integratedTerminal",
    },
    {
      name = "附加到 node 进程",
      type = "pwa-node",
      request = "attach",
      processId = require("dap.utils").pick_process,
      cwd = "${workspaceFolder}",
    },
  }

  for _, ft in ipairs({ "javascript", "javascriptreact", "typescript", "typescriptreact" }) do
    dap.configurations[ft] = js_configs
  end
else
  warn_missing("js-debug-adapter", "JavaScript / TypeScript")
end

------------------------------------------------------------------------------
-- Java：jdtls 代理（java-debug 的 jar 在 lspconfig.lua 里挂成 bundles）
-- 流程：让 jdtls 执行 vscode.java.startDebugSession 拿到 DAP 端口
------------------------------------------------------------------------------
local function jdtls_client()
  for _, client in ipairs(vim.lsp.get_clients({ name = "jdtls" })) do
    return client
  end
end

dap.adapters.java = function(cb)
  -- 适配器必须调 cb，否则 nvim-dap 会一直干等；拿不到端口时给个无效端口让它立刻报错
  local function fail(msg)
    vim.notify(msg, vim.log.levels.ERROR)
    cb({ type = "server", host = "127.0.0.1", port = 0 })
  end

  local client = jdtls_client()
  if not client then
    return fail("Java 调试需要 jdtls 先跑起来：打开任意 .java 文件即可")
  end

  local port
  client:request("workspace/executeCommand", { command = "vscode.java.startDebugSession" }, function(err, result)
    if err then
      vim.notify("启动 java-debug 失败：" .. (err.message or tostring(err)), vim.log.levels.ERROR)
      return
    end
    port = tonumber(result)
  end, 0)

  -- 等 jdtls 回消息（一般几十毫秒）
  vim.wait(3000, function() return port ~= nil end, 20)
  if not port then
    return fail("java-debug 没有返回端口：检查 mason 是否装好 java-debug-adapter，或重启后重试")
  end

  cb({ type = "server", host = "127.0.0.1", port = port })
end

-- 从 buffer 里推出 main class（package + 类名），单文件调试不用手填
local function java_main_class()
  local package, class
  for _, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
    package = package or line:match("^%s*package%s+([%w_%.]+)%s*;")
    class = class or line:match("^%s*[%w_%s]-%f[%w]class%s+([%w_]+)")
      or line:match("^%s*[%w_%s]-%f[%w]record%s+([%w_]+)")
      or line:match("^%s*[%w_%s]-%f[%w]enum%s+([%w_]+)")
  end
  if not class then
    class = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t:r")
  end
  return package and (package .. "." .. class) or class
end

dap.configurations.java = {
  {
    type = "java",
    request = "launch",
    name = "启动当前文件",
    mainClass = java_main_class,
    cwd = "${workspaceFolder}",
  },
  {
    type = "java",
    request = "launch",
    name = "启动当前文件（带参数…）",
    mainClass = java_main_class,
    args = function()
      return vim.split(vim.fn.input("参数: "), " ", { trimempty = true })
    end,
    cwd = "${workspaceFolder}",
  },
  {
    type = "java",
    request = "attach",
    name = "附加到远程 (5005)",
    hostName = "127.0.0.1",
    port = 5005,
  },
}

------------------------------------------------------------------------------
-- 快捷键
------------------------------------------------------------------------------
local map = vim.keymap.set

map("n", "<F5>", function() dap.continue() end, { desc = "调试：继续/开始" })
map("n", "<F10>", function() dap.step_over() end, { desc = "调试：单步跳过" })
map("n", "<F11>", function() dap.step_into() end, { desc = "调试：单步进入" })
map("n", "<F12>", function() dap.step_out() end, { desc = "调试：单步跳出" })

map("n", "<leader>db", function() dap.toggle_breakpoint() end, { desc = "断点开关" })
map("n", "<leader>dB", function()
  dap.set_breakpoint(vim.fn.input("条件: "))
end, { desc = "条件断点" })
map("n", "<leader>dc", function() dap.run_to_cursor() end, { desc = "运行到光标行" })
map("n", "<leader>dr", function() dap.repl.toggle() end, { desc = "调试 REPL" })
map("n", "<leader>du", function() dapui.toggle() end, { desc = "调试面板开关" })
map("n", "<leader>dx", function() dap.terminate() end, { desc = "结束调试" })
map("n", "<leader>dl", function() dap.run_last() end, { desc = "重跑上次调试" })
