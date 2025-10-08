return {
  {
    "jake-stewart/multicursor.nvim",
    config = function()
      local mc = require("multicursor-nvim")
      mc.setup()
      mc.addKeymapLayer(function(layerSet)
        layerSet({ "n", "x" }, "k", mc.prevCursor)
        layerSet({ "n", "x" }, "j", mc.nextCursor)

        layerSet({ "n", "x" }, "x", mc.deleteCursor)

        layerSet("n", "<esc>", function()
          if not mc.cursorsEnabled() then
            mc.enableCursors()
          else
            mc.clearCursors()
          end
        end)
      end)
    end,
    keys = {
      {
        "<C-n>",
        function()
          local mc = require("multicursor-nvim")
          mc.matchAddCursor(1)
        end,
        mode = { "n", "v" },
        desc = "Multicursor: Add Cursor",
      },
      {
        "<leader>ma",
        function()
          local mc = require("multicursor-nvim")
          mc.matchAllAddCursors()
        end,
        mode = { "n", "v" },
        desc = "Multicursor: Add All Cursor",
      },
      {
        "<leader>ms",
        function()
          local mc = require("multicursor-nvim")
          mc.matchSkipCursor(1)
        end,
        mode = { "n", "v" },
        desc = "Multicursor: Skip Cursor",
      },
    },
  },
}
