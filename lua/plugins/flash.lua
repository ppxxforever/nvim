vim.pack.add({ "https://github.com/folke/flash.nvim" })

require("flash").setup({})

local map = vim.keymap.set

map({ "n", "x", "o" }, "s", function() require("flash").jump() end, { desc = "Flash 跳转" })
map({ "n", "x", "o" }, "S", function() require("flash").treesitter() end, { desc = "Flash 语法跳转" })
map({ "o" }, "r", function() require("flash").remote() end, { desc = "Flash 远程操作" })
map({ "o", "x" }, "R", function() require("flash").treesitter_search() end, { desc = "Flash 语法搜索" })
map({ "c" }, "<c-s>", function() require("flash").toggle() end, { desc = "Flash 搜索开关" })
