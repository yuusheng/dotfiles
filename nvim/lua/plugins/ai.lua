return {
  {
    "zbirenbaum/copilot.lua",
    event = function()
      return { "InsertEnter" }
    end,
  },
  {
    "folke/sidekick.nvim",
    opts = {
      nes = { enabled = false },
      cli = {
        tools = {
          droid = {
            cmd = { "droid" },
          },
        },
      },
    },
  },
}
