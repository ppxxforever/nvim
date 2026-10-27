vim.pack.add({ "https://github.com/nvim-treesitter/nvim-treesitter" })

-- 需要高亮的语言（.c3/.c3i/.c3t 由 Neovim 内置识别为 filetype=c3）
local langs = {
  "lua",
  "python",
  "vim",
  -- markdown 写作：markdown 负责块级结构，markdown_inline 负责行内强调/链接/代码
  "markdown",
  "markdown_inline",
  -- markdown 里嵌的代码块要高亮就得有对应解析器
  "bash",
  "json",
  "yaml",
  "css",
  "html",
  -- 前端
  "javascript",
  "typescript",
  "tsx",
  "jsdoc",
  -- 编译型
  "c",
  "cpp",
  "c_sharp",
  "java",
  -- C3（c3lang/tree-sitter-c3）
  "c3",
}

-- 1. 安装语言解析器（新 API）
-- install 是异步的，如果你想确保启动时解析器已就绪，可以加上 :wait()
require("nvim-treesitter").install(langs)

-- 2. 在 Neovim 0.12 中，语法高亮由 Neovim 本体提供，不再由插件负责
-- 通过自动命令为已安装解析器的文件类型开启高亮
vim.api.nvim_create_autocmd("FileType", {
  pattern = langs,
  callback = function()
    vim.treesitter.start()
  end,
})
