require("gruvbox").setup({
  terminal_colors = true, -- add neovim terminal colors
  undercurl = true,
  underline = true,
  bold = true,
  italic = {
    strings = true,
    emphasis = true,
    comments = true,
    operators = false,
    folds = true
  },
  strikethrough = true,
  invert_selection = false,
  invert_signs = false,
  invert_tabline = false,
  inverse = true, -- invert background for search, diffs, statuslines and errors
  contrast = "", -- can be "hard", "soft" or empty string
  palette_overrides = {},
  overrides = {},
  dim_inactive = false,
  transparent_mode = false
})

vim.cmd([[colorscheme gruvbox]])
vim.cmd("so " .. vim.g.vimhome .. "/conf/gruvbox_conf.vim")

local function get_gruv_color(group)
  local gui_color = vim.fn.synIDattr(vim.fn.hlID(group), "fg", "gui")
  return {gui_color, "None"}
end

local function lightline_color()
  local bg0 = get_gruv_color("GruvboxBg0")
  local bg1 = get_gruv_color("GruvboxBg1")
  local bg2 = get_gruv_color("GruvboxBg2")
  local bg4 = get_gruv_color("GruvboxBg4")
  local fg1 = get_gruv_color("GruvboxFg1")
  local fg4 = get_gruv_color("GruvboxFg4")

  local yellow = get_gruv_color("GruvboxYellow")
  local blue = get_gruv_color("GruvboxBlue")
  local aqua = get_gruv_color("GruvboxAqua")
  local orange = get_gruv_color("GruvboxOrange")
  local green = get_gruv_color("GruvboxGreen")

  local p = {
    normal = {
      left = {{bg0, fg4, "bold"}, {fg4, bg2}},
      right = {{bg0, fg4}, {fg4, bg2}},
      middle = {{fg4, bg1}},
      error = {{bg0, orange}},
      warning = {{bg2, yellow}}
    },
    inactive = {
      right = {{bg4, bg1}, {bg4, bg1}},
      left = {{bg4, bg1}, {bg4, bg1}},
      middle = {{bg4, bg1}}
    },
    insert = {
      left = {{bg0, blue, "bold"}, {fg1, bg2}},
      right = {{bg0, blue}, {fg1, bg2}},
      middle = {{fg4, bg2}}
    },
    terminal = {
      left = {{bg0, green, "bold"}, {fg1, bg2}},
      right = {{bg0, green}, {fg1, bg2}},
      middle = {{fg4, bg2}}
    },
    replace = {
      left = {{bg0, aqua, "bold"}, {fg1, bg2}},
      right = {{bg0, aqua}, {fg1, bg2}},
      middle = {{fg4, bg2}}
    },
    visual = {
      left = {{bg0, orange, "bold"}, {bg0, bg4}},
      right = {{bg0, orange}, {bg0, bg4}},
      middle = {{fg4, bg1}}
    },
    tabline = {
      left = {{fg4, bg2}},
      tabsel = {{bg0, fg4}},
      middle = {{bg0, bg0}},
      right = {{bg0, orange}}
    }
  }

  vim.g["lightline#colorscheme#gruvbox#palette"] = vim.call(
                                                       "lightline#colorscheme#flatten",
                                                       p)

  -- vim.cmd("let g:lightline.colorscheme = \"gruvbox\"")
  local lightline = vim.g.lightline
  lightline.colorscheme = "gruvbox"
  vim.g.lightline = lightline
end

lightline_color()
