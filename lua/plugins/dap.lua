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
-- Python 适配器
-- mason 的 debugpy 装不了（系统缺 python3-venv），改用 uv 建的独立 venv
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
