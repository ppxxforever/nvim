vim.pack.add({ "https://github.com/NeogitOrg/neogit" })
vim.pack.add({ "https://github.com/nvim-lua/plenary.nvim" })

require("neogit").setup({})

vim.keymap.set("n", "<leader>gs", "<cmd>Neogit<cr>", { desc = "Git 状态", silent = true })
