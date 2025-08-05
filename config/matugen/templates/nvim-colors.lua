-- Auto-generated colorscheme from matugen
-- Based on current wallpaper colors

local M = {}

M.colors = {
  bg = "{{colors.surface.default.hex}}",
  bg_alt = "{{colors.surface_container.default.hex}}",
  bg_highlight = "{{colors.surface_container_high.default.hex}}",
  fg = "{{colors.on_surface.default.hex}}",
  fg_alt = "{{colors.on_surface_variant.default.hex}}",
  
  primary = "{{colors.primary.default.hex}}",
  primary_bg = "{{colors.primary_container.default.hex}}",
  primary_fg = "{{colors.on_primary_container.default.hex}}",
  
  secondary = "{{colors.secondary.default.hex}}",
  secondary_bg = "{{colors.secondary_container.default.hex}}",
  secondary_fg = "{{colors.on_secondary_container.default.hex}}",
  
  tertiary = "{{colors.tertiary.default.hex}}",
  tertiary_bg = "{{colors.tertiary_container.default.hex}}",
  tertiary_fg = "{{colors.on_tertiary_container.default.hex}}",
  
  error = "{{colors.error.default.hex}}",
  error_bg = "{{colors.error_container.default.hex}}",
  error_fg = "{{colors.on_error_container.default.hex}}",
  
  warning = "{{colors.tertiary.default.hex}}",
  info = "{{colors.secondary.default.hex}}",
  hint = "{{colors.primary.default.hex}}",
  
  border = "{{colors.outline.default.hex}}",
  selection = "{{colors.surface_container_highest.default.hex}}",
  comment = "{{colors.outline.default.hex}}",
  
  -- Git colors
  git_add = "{{colors.secondary.default.hex}}",
  git_change = "{{colors.tertiary.default.hex}}",
  git_delete = "{{colors.error.default.hex}}",
  
  -- Diagnostic colors
  diagnostic_error = "{{colors.error.default.hex}}",
  diagnostic_warn = "{{colors.tertiary.default.hex}}",
  diagnostic_info = "{{colors.secondary.default.hex}}",
  diagnostic_hint = "{{colors.primary.default.hex}}",
}

function M.setup()
  vim.cmd("hi clear")
  if vim.fn.exists("syntax_on") then
    vim.cmd("syntax reset")
  end
  
  vim.g.colors_name = "matugen"
  vim.o.background = "dark"
  
  local c = M.colors
  
  -- Editor highlights
  vim.api.nvim_set_hl(0, "Normal", { fg = c.fg, bg = c.bg })
  vim.api.nvim_set_hl(0, "NormalFloat", { fg = c.fg, bg = c.bg_alt })
  vim.api.nvim_set_hl(0, "NormalNC", { fg = c.fg, bg = c.bg })
  
  vim.api.nvim_set_hl(0, "LineNr", { fg = c.comment })
  vim.api.nvim_set_hl(0, "CursorLineNr", { fg = c.primary, bold = true })
  vim.api.nvim_set_hl(0, "CursorLine", { bg = c.bg_highlight })
  vim.api.nvim_set_hl(0, "ColorColumn", { bg = c.bg_highlight })
  
  vim.api.nvim_set_hl(0, "Visual", { bg = c.selection })
  vim.api.nvim_set_hl(0, "Search", { fg = c.primary_fg, bg = c.primary_bg })
  vim.api.nvim_set_hl(0, "IncSearch", { fg = c.primary_fg, bg = c.primary, bold = true })
  
  vim.api.nvim_set_hl(0, "Pmenu", { fg = c.fg, bg = c.bg_alt })
  vim.api.nvim_set_hl(0, "PmenuSel", { fg = c.primary_fg, bg = c.primary_bg })
  vim.api.nvim_set_hl(0, "PmenuSbar", { bg = c.bg_highlight })
  vim.api.nvim_set_hl(0, "PmenuThumb", { bg = c.primary })
  
  vim.api.nvim_set_hl(0, "StatusLine", { fg = c.fg, bg = c.bg_alt })
  vim.api.nvim_set_hl(0, "StatusLineNC", { fg = c.comment, bg = c.bg_alt })
  vim.api.nvim_set_hl(0, "WinSeparator", { fg = c.border })
  
  vim.api.nvim_set_hl(0, "TabLine", { fg = c.comment, bg = c.bg_alt })
  vim.api.nvim_set_hl(0, "TabLineFill", { bg = c.bg_alt })
  vim.api.nvim_set_hl(0, "TabLineSel", { fg = c.primary, bg = c.bg, bold = true })
  
  -- Syntax highlights
  vim.api.nvim_set_hl(0, "Comment", { fg = c.comment, italic = true })
  vim.api.nvim_set_hl(0, "Constant", { fg = c.tertiary })
  vim.api.nvim_set_hl(0, "String", { fg = c.secondary })
  vim.api.nvim_set_hl(0, "Character", { fg = c.secondary })
  vim.api.nvim_set_hl(0, "Number", { fg = c.tertiary })
  vim.api.nvim_set_hl(0, "Boolean", { fg = c.tertiary })
  vim.api.nvim_set_hl(0, "Float", { fg = c.tertiary })
  
  vim.api.nvim_set_hl(0, "Identifier", { fg = c.fg })
  vim.api.nvim_set_hl(0, "Function", { fg = c.primary })
  
  vim.api.nvim_set_hl(0, "Statement", { fg = c.primary, bold = true })
  vim.api.nvim_set_hl(0, "Conditional", { fg = c.primary, bold = true })
  vim.api.nvim_set_hl(0, "Repeat", { fg = c.primary, bold = true })
  vim.api.nvim_set_hl(0, "Label", { fg = c.primary })
  vim.api.nvim_set_hl(0, "Operator", { fg = c.fg })
  vim.api.nvim_set_hl(0, "Keyword", { fg = c.primary, bold = true })
  vim.api.nvim_set_hl(0, "Exception", { fg = c.error, bold = true })
  
  vim.api.nvim_set_hl(0, "PreProc", { fg = c.tertiary })
  vim.api.nvim_set_hl(0, "Include", { fg = c.tertiary })
  vim.api.nvim_set_hl(0, "Define", { fg = c.tertiary })
  vim.api.nvim_set_hl(0, "Macro", { fg = c.tertiary })
  vim.api.nvim_set_hl(0, "PreCondit", { fg = c.tertiary })
  
  vim.api.nvim_set_hl(0, "Type", { fg = c.secondary, bold = true })
  vim.api.nvim_set_hl(0, "StorageClass", { fg = c.secondary })
  vim.api.nvim_set_hl(0, "Structure", { fg = c.secondary })
  vim.api.nvim_set_hl(0, "Typedef", { fg = c.secondary })
  
  vim.api.nvim_set_hl(0, "Special", { fg = c.tertiary })
  vim.api.nvim_set_hl(0, "SpecialChar", { fg = c.tertiary })
  vim.api.nvim_set_hl(0, "Tag", { fg = c.primary })
  vim.api.nvim_set_hl(0, "Delimiter", { fg = c.fg })
  vim.api.nvim_set_hl(0, "SpecialComment", { fg = c.comment, bold = true })
  vim.api.nvim_set_hl(0, "Debug", { fg = c.error })
  
  vim.api.nvim_set_hl(0, "Underlined", { fg = c.primary, underline = true })
  vim.api.nvim_set_hl(0, "Error", { fg = c.error, bold = true })
  vim.api.nvim_set_hl(0, "Todo", { fg = c.warning, bold = true })
  
  -- Diagnostic highlights
  vim.api.nvim_set_hl(0, "DiagnosticError", { fg = c.diagnostic_error })
  vim.api.nvim_set_hl(0, "DiagnosticWarn", { fg = c.diagnostic_warn })
  vim.api.nvim_set_hl(0, "DiagnosticInfo", { fg = c.diagnostic_info })
  vim.api.nvim_set_hl(0, "DiagnosticHint", { fg = c.diagnostic_hint })
  
  vim.api.nvim_set_hl(0, "DiagnosticUnderlineError", { undercurl = true, sp = c.diagnostic_error })
  vim.api.nvim_set_hl(0, "DiagnosticUnderlineWarn", { undercurl = true, sp = c.diagnostic_warn })
  vim.api.nvim_set_hl(0, "DiagnosticUnderlineInfo", { undercurl = true, sp = c.diagnostic_info })
  vim.api.nvim_set_hl(0, "DiagnosticUnderlineHint", { undercurl = true, sp = c.diagnostic_hint })
  
  -- Git highlights
  vim.api.nvim_set_hl(0, "DiffAdd", { fg = c.git_add, bg = c.bg_alt })
  vim.api.nvim_set_hl(0, "DiffChange", { fg = c.git_change, bg = c.bg_alt })
  vim.api.nvim_set_hl(0, "DiffDelete", { fg = c.git_delete, bg = c.bg_alt })
  vim.api.nvim_set_hl(0, "DiffText", { fg = c.git_change, bg = c.bg_highlight, bold = true })
  
  -- TreeSitter highlights
  vim.api.nvim_set_hl(0, "@variable", { fg = c.fg })
  vim.api.nvim_set_hl(0, "@variable.builtin", { fg = c.tertiary })
  vim.api.nvim_set_hl(0, "@variable.parameter", { fg = c.fg })
  vim.api.nvim_set_hl(0, "@variable.member", { fg = c.secondary })
  
  vim.api.nvim_set_hl(0, "@constant", { fg = c.tertiary })
  vim.api.nvim_set_hl(0, "@constant.builtin", { fg = c.tertiary, bold = true })
  vim.api.nvim_set_hl(0, "@constant.macro", { fg = c.tertiary })
  
  vim.api.nvim_set_hl(0, "@module", { fg = c.secondary })
  vim.api.nvim_set_hl(0, "@label", { fg = c.primary })
  
  vim.api.nvim_set_hl(0, "@string", { fg = c.secondary })
  vim.api.nvim_set_hl(0, "@string.documentation", { fg = c.comment })
  vim.api.nvim_set_hl(0, "@string.regexp", { fg = c.tertiary })
  vim.api.nvim_set_hl(0, "@string.escape", { fg = c.tertiary, bold = true })
  
  vim.api.nvim_set_hl(0, "@character", { fg = c.secondary })
  vim.api.nvim_set_hl(0, "@character.special", { fg = c.tertiary })
  
  vim.api.nvim_set_hl(0, "@boolean", { fg = c.tertiary })
  vim.api.nvim_set_hl(0, "@number", { fg = c.tertiary })
  vim.api.nvim_set_hl(0, "@number.float", { fg = c.tertiary })
  
  vim.api.nvim_set_hl(0, "@type", { fg = c.secondary })
  vim.api.nvim_set_hl(0, "@type.builtin", { fg = c.secondary, bold = true })
  vim.api.nvim_set_hl(0, "@type.definition", { fg = c.secondary, bold = true })
  
  vim.api.nvim_set_hl(0, "@attribute", { fg = c.tertiary })
  vim.api.nvim_set_hl(0, "@property", { fg = c.secondary })
  
  vim.api.nvim_set_hl(0, "@function", { fg = c.primary })
  vim.api.nvim_set_hl(0, "@function.builtin", { fg = c.primary, bold = true })
  vim.api.nvim_set_hl(0, "@function.call", { fg = c.primary })
  vim.api.nvim_set_hl(0, "@function.macro", { fg = c.tertiary })
  
  vim.api.nvim_set_hl(0, "@method", { fg = c.primary })
  vim.api.nvim_set_hl(0, "@method.call", { fg = c.primary })
  
  vim.api.nvim_set_hl(0, "@constructor", { fg = c.secondary })
  
  vim.api.nvim_set_hl(0, "@keyword", { fg = c.primary, bold = true })
  vim.api.nvim_set_hl(0, "@keyword.function", { fg = c.primary, bold = true })
  vim.api.nvim_set_hl(0, "@keyword.operator", { fg = c.primary })
  vim.api.nvim_set_hl(0, "@keyword.return", { fg = c.primary, bold = true })
  vim.api.nvim_set_hl(0, "@keyword.conditional", { fg = c.primary, bold = true })
  vim.api.nvim_set_hl(0, "@keyword.repeat", { fg = c.primary, bold = true })
  vim.api.nvim_set_hl(0, "@keyword.exception", { fg = c.error, bold = true })
  
  vim.api.nvim_set_hl(0, "@operator", { fg = c.fg })
  
  vim.api.nvim_set_hl(0, "@punctuation.delimiter", { fg = c.fg })
  vim.api.nvim_set_hl(0, "@punctuation.bracket", { fg = c.fg })
  vim.api.nvim_set_hl(0, "@punctuation.special", { fg = c.tertiary })
  
  vim.api.nvim_set_hl(0, "@comment", { fg = c.comment, italic = true })
  vim.api.nvim_set_hl(0, "@comment.documentation", { fg = c.comment, italic = true })
  
  vim.api.nvim_set_hl(0, "@tag", { fg = c.primary })
  vim.api.nvim_set_hl(0, "@tag.attribute", { fg = c.secondary })
  vim.api.nvim_set_hl(0, "@tag.delimiter", { fg = c.fg })
  
  -- LSP semantic tokens
  vim.api.nvim_set_hl(0, "@lsp.type.class", { fg = c.secondary })
  vim.api.nvim_set_hl(0, "@lsp.type.decorator", { fg = c.tertiary })
  vim.api.nvim_set_hl(0, "@lsp.type.enum", { fg = c.secondary })
  vim.api.nvim_set_hl(0, "@lsp.type.enumMember", { fg = c.tertiary })
  vim.api.nvim_set_hl(0, "@lsp.type.function", { fg = c.primary })
  vim.api.nvim_set_hl(0, "@lsp.type.interface", { fg = c.secondary })
  vim.api.nvim_set_hl(0, "@lsp.type.macro", { fg = c.tertiary })
  vim.api.nvim_set_hl(0, "@lsp.type.method", { fg = c.primary })
  vim.api.nvim_set_hl(0, "@lsp.type.namespace", { fg = c.secondary })
  vim.api.nvim_set_hl(0, "@lsp.type.parameter", { fg = c.fg })
  vim.api.nvim_set_hl(0, "@lsp.type.property", { fg = c.secondary })
  vim.api.nvim_set_hl(0, "@lsp.type.struct", { fg = c.secondary })
  vim.api.nvim_set_hl(0, "@lsp.type.type", { fg = c.secondary })
  vim.api.nvim_set_hl(0, "@lsp.type.typeParameter", { fg = c.secondary })
  vim.api.nvim_set_hl(0, "@lsp.type.variable", { fg = c.fg })
end

return M