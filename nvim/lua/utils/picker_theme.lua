local M = {}

function M.apply()
  local ok, palettes = pcall(require, "catppuccin.palettes")
  if not ok then
    return
  end

  local colors = palettes.get_palette()
  local highlights = {
    UnifiedPickerMatch = { fg = colors.flamingo },
    UnifiedPickerSelection = { fg = colors.text, bg = colors.surface0, bold = true },
    UnifiedPickerPrompt = { fg = colors.pink, bg = colors.surface0 },

    UnifiedPickerInput = { fg = colors.text, bg = colors.surface0 },
    UnifiedPickerInputBorder = { fg = colors.surface0, bg = colors.surface0 },
    UnifiedPickerInputTitle = { fg = colors.mantle, bg = colors.pink },

    UnifiedPickerList = { bg = colors.mantle },
    UnifiedPickerListBorder = { fg = colors.mantle, bg = colors.mantle },
    UnifiedPickerListTitle = { fg = colors.mantle, bg = colors.mantle },

    UnifiedPickerPreview = { bg = colors.mantle },
    UnifiedPickerPreviewBorder = { fg = colors.mantle, bg = colors.mantle },
    UnifiedPickerPreviewTitle = { fg = colors.mantle, bg = colors.green },

    SnacksPickerMatch = { link = "UnifiedPickerMatch" },
    SnacksPickerListCursorLine = { link = "UnifiedPickerSelection" },
    SnacksPickerPrompt = { link = "UnifiedPickerPrompt" },
    SnacksPickerInputSearch = { link = "UnifiedPickerInput" },
    SnacksPickerInput = { link = "UnifiedPickerInput" },
    SnacksPickerInputCursorLine = { link = "UnifiedPickerInput" },
    SnacksPickerInputBorder = { link = "UnifiedPickerInputBorder" },
    SnacksPickerInputTitle = { link = "UnifiedPickerInputTitle" },
    SnacksPickerList = { link = "UnifiedPickerList" },
    SnacksPickerListBorder = { link = "UnifiedPickerListBorder" },
    SnacksPickerListTitle = { link = "UnifiedPickerListTitle" },
    SnacksPickerPreview = { link = "UnifiedPickerPreview" },
    SnacksPickerPreviewBorder = { link = "UnifiedPickerPreviewBorder" },
    SnacksPickerPreviewTitle = { link = "UnifiedPickerPreviewTitle" },
  }

  for group, highlight in pairs(highlights) do
    vim.api.nvim_set_hl(0, group, highlight)
  end
end

function M.setup()
  if M._setup then
    return
  end
  M._setup = true

  vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("unified_picker_theme", { clear = true }),
    pattern = "catppuccin*",
    callback = M.apply,
  })
  vim.schedule(M.apply)
end

return M
