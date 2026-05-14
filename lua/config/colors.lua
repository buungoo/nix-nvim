local M = {}

local kanagawa_colors = require('kanagawa.colors').setup({ theme = 'wave' })
local palette = kanagawa_colors and kanagawa_colors.palette or {}

M.search = palette.roninYellow
M.search_bg = palette.sumiInk0
M.indent = palette.sumiInk5
M.chunk = palette.roninYellow
M.chunk_error = palette.autumnRed

M.picker_match = palette.roninYellow
M.picker_border = palette.roninYellow --.sumiInk4
M.picker_header = palette.springGreen
M.picker_info = palette.waveAqua2

M.line_nr = palette.roninYellow
M.line_nr_bg = palette.sumiInk6
M.mode_insert = palette.dragonPink
M.mode_visual = palette.waveAqua2
M.mode_vline = palette.waveAqua1
M.mode_replace = palette.autumnRed

return M
