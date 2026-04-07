return {
    "NeogitOrg/neogit",
    cmd = "Neogit",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope.nvim",
    },
    keys = {
        { "<leader>gg", "<cmd>Neogit<CR>", desc = "Open Neogit UI" },
    },
    config = function()
        require("neogit").setup({
            integrations = {
                telescope = true,
            },
        })
    end,
}
