-- ============================================================================
-- 运行时 PATH：Java / .NET 装在用户目录（scripts/bootstrap-toolchain.sh 装的），
-- 这里只把它们的 bin 塞进 Neovim 自己的环境变量，不改你的 shell 配置。
-- 必须有：
--   jdtls / google-java-format 是 shell 脚本，要靠 PATH 找到 `java`
--   roslyn / csharpier 是 nuget 工具，要靠 DOTNET_ROOT + PATH 找到 `dotnet`
-- 必须在所有插件之前 require（mason.setup 会基于当前 PATH 做检查）。
-- ============================================================================
local function prepend_path(dir)
  if dir == "" or vim.fn.isdirectory(dir) == 0 then return end
  local path = vim.env.PATH or ""
  if path:find(dir, 1, true) then return end -- 已经在 PATH 里就不重复加
  vim.env.PATH = dir .. ":" .. path
end

local home = vim.env.HOME

-- JDK：只有 25 能跑 mason 版的 jdtls（它的 bundle 写了 osgi.ee=JavaSE 25）
local jdk = (function()
  for _, v in ipairs({ "25", "21" }) do
    local dir = ("%s/.local/share/jdk-%s"):format(home, v)
    if vim.fn.isdirectory(dir) == 1 then return dir end
  end
end)()

if jdk then
  prepend_path(jdk .. "/bin") -- java / javac
  vim.env.JAVA_HOME = jdk
end

prepend_path(home .. "/.dotnet") -- dotnet SDK
prepend_path(home .. "/.dotnet/tools") -- dotnet 全局工具（csharp-ls 之类）

-- .NET 装在非标准路径时，apphost（roslyn-language-server / csharpier 这类）
-- 不会去 PATH 找 dotnet，必须给 DOTNET_ROOT
if vim.fn.isdirectory(home .. "/.dotnet") == 1 then
  vim.env.DOTNET_ROOT = home .. "/.dotnet"
end
