-- 内置 :terminal 的便利封装：底部复用终端 + 浮动终端
-- 内置命令速查：:terminal（当前窗口）、:vsplit | terminal、:tab terminal
-- 在终端里想回到普通模式：<C-\><C-n>（<C-\><C-o> 执行一条命令后回到终端）

local state = { buf = nil, win = nil } -- 底部终端
local float = { buf = nil, win = nil } -- 浮动终端

local function buf_alive(buf)
  return buf ~= nil and vim.api.nvim_buf_is_valid(buf)
end

local function win_alive(win)
  return win ~= nil and vim.api.nvim_win_is_valid(win)
end

-- 底部终端：再按一次就收起（buffer 保留，shell 不退出，历史还在）
local function toggle_bottom()
  if win_alive(state.win) then
    vim.api.nvim_win_hide(state.win)
    state.win = nil
    return
  end

  vim.cmd("botright 12split")
  state.win = vim.api.nvim_get_current_win()
  if buf_alive(state.buf) then
    vim.api.nvim_win_set_buf(state.win, state.buf)
  else
    vim.cmd("terminal")
    state.buf = vim.api.nvim_get_current_buf()
  end
  vim.cmd("startinsert")
end

-- 浮动终端：80% x 75% 居中
local function toggle_float()
  if win_alive(float.win) then
    vim.api.nvim_win_hide(float.win)
    float.win = nil
    return
  end

  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.75)
  local scratch = vim.api.nvim_create_buf(false, true) -- 只为开窗占位
  float.win = vim.api.nvim_open_win(scratch, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2) - 1,
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = "rounded",
  })

  if buf_alive(float.buf) then
    vim.api.nvim_win_set_buf(float.win, float.buf)
    vim.api.nvim_buf_delete(scratch, { force = true })
  else
    vim.cmd("terminal") -- 在当前（浮动）窗口里开 shell
    float.buf = vim.api.nvim_get_current_buf()
  end
  vim.cmd("startinsert")
end

vim.keymap.set("n", "<leader>tt", toggle_bottom, { desc = "终端：底部开关" })
vim.keymap.set("n", "<leader>tf", toggle_float, { desc = "终端：浮动开关" })

-- 终端里 <Esc> 不劫持（vim/htop 之类要用它），保留 Neovim 原生的 <C-\><C-n>
-- 想让 Esc 也能退出终端模式，取消下面注释（代价：嵌套程序里的 Esc 会先被 Neovim 吃掉一次）
-- vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "退出终端模式" })
