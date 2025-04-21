return {
  {
    "echasnovski/mini.ai",
    opts = function()
      local ai = require("mini.ai")

      return {
        custom_textobjects = {
          x = ai.gen_spec.treesitter({ a = "@attribute.outer", i = "@attribute.inner" }),
        },
      }
    end,
  },
}
