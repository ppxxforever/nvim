vim.pack.add({ "https://github.com/lewis6991/gitsigns.nvim" })

require("gitsigns").setup({
  signcolumn = true,
  current_line_blame = false,
})

local map = vim.keymap.set

-- Hunk 导航（gitsigns 默认还提供 ]c / [c）
map("n", "]h", function() require("gitsigns").next_hunk() end, { desc = "下一个改动块" })
map("n", "[h", function() require("gitsigns").prev_hunk() end, { desc = "上一个改动块" })

-- Hunk 操作
map("n", "<leader>hs", function() require("gitsigns").stage_hunk() end, { desc = "暂存改动块" })
map("n", "<leader>hr", function() require("gitsigns").reset_hunk() end, { desc = "撤销改动块" })
map("n", "<leader>hp", function() require("gitsigns").preview_hunk() end, { desc = "预览改动块" })
map("n", "<leader>hu", function() require("gitsigns").undo_stage_hunk() end, { desc = "取消暂存" })

-- Blame / diff
map("n", "<leader>hb", function() require("gitsigns").blame_line({ full = true }) end, { desc = "行 blame" })
map("n", "<leader>hB", "<cmd>Gitsigns toggle_current_line_blame<cr>", { desc = "行尾 blame 开关" })
map("n", "<leader>hd", function() require("gitsigns").diffthis() end, { desc = "diff 当前文件" })
