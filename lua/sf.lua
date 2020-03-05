local window = require 'lib/window'
local loop = require 'lib/loop'
local Parser = require 'lib/parser'
local api = vim.api

local parser

local function onread(data)
  local buf = window.getbuf()
  local l_parser = Parser.new()
  l_parser:parse(data)
  l_parser:draw()

  parser:merge(l_parser)
  window.set({'Match count: ' .. parser.match_count .. ' in ' .. parser.files_count .. ' files'}, 0, 1)
end

local function onexit()
  window.set({'Match count: ' .. parser.match_count .. ' in ' .. parser.files_count .. ' files - Done!'}, 0, 1)
  window.color('SuperFindGreen', 0, 0, -1)
end

local function enter()
  local line = api.nvim_win_get_cursor(0)
  local data = parser.data[line[1] - 1]
  local win = window.getoldwin()

  api.nvim_set_current_win(win)
  api.nvim_command('e ' .. data['path'])
  api.nvim_win_set_cursor(win, {data.line_nr, 0})
  api.nvim_command('normal! zz')
end

local function quit()
  print 'wow'
  loop.close()
  window.close()
end

local function stop()
  print 'asdf'
  loop.close(function()
    window.set({
        'Match count: ' .. parser.match_count .. ' in ' .. parser.files_count .. ' files - Stopped!',
      }, 0, 1)
    window.color('SuperFindRed', 0, 0, -1)
  end)
end

local function sf(arg)
  collectgarbage()
  window.open_or_focus()

  window.set_mapping('<cr>', 'enter()')
  window.set_mapping('q', 'quit()')
  window.set_mapping('<c-c>', 'stop()')

  parser = Parser:new()
  loop.call('rg', {
      arg,
      '-iPn',
      '--max-columns=500',
      '-C=3',
      '--json',
    }, onread, onexit)
end

return {
  sf = sf,
  enter = enter,
  quit = quit,
  stop = stop
}
