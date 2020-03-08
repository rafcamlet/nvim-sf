local window = require 'lib/window'
local api = vim.api

local function firstline(data)
  local status = ''

  match_count = tostring(tonumber(data['match_count']))
  files_count = tostring(tonumber(data['files_count']))

  status = status .. 'Match count: '
  status = status .. match_count
  status = status .. ' in '
  status = status .. files_count .. ' files'
  if data['finished'] then
    status = status .. ' - Done!'
  end

  window.set({ status }, 0, 1)

  if data['finished'] then
    window.color('SuperFindGreen', 0, 0, -1)
  end
end

local function statusline(data)
  local status

  match_count = tostring(tonumber(data['match_count']))
  files_count = tostring(tonumber(data['files_count']))

  if data['finished'] then
    status = '%#SuperFindStGreen#'
  else
    status = '%#Base#'
  end
  status = status .. '  SuperFind -- '
  status = status .. match_count .. ' matches'
  status = status .. ' in '
  status = status .. files_count .. ' files'
  status = status .. '%='
  status = status .. string.format('%.4fs', tostring(data['clock']))
  status = status .. ' '

  api.nvim_win_set_option(window.getwin(), 'statusline', status)
end

return {
  statusline = statusline,
  firstline = firstline
}
