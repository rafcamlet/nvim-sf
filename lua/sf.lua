local window = require 'lib/window'
local loop = require 'lib/loop'
local Parser = require 'lib/parser'
local parse_args = require 'lib/args'.parse_args
local api = vim.api
local clock = 0
local parser

local function onread(data)
  local l_parser = Parser.new()
  l_parser:parse(data)
  l_parser:draw()

  parser:merge(l_parser)
  window.set({'Match count: ' .. parser.match_count .. ' in ' .. parser.files_count .. ' files'}, 0, 1)
  window.set({ tostring(os.clock() - clock ) }, 1, 2)
end

local function onexit()
  window.set({'Match count: ' .. parser.match_count .. ' in ' .. parser.files_count .. ' files - Done!'}, 0, 1)
  window.color('SuperFindGreen', 0, 0, -1)
  window.color('SuperFindGreen', 1, 0, -1)
  collectgarbage()
end

local function enter()
  local line = api.nvim_win_get_cursor(0)
  local data = parser.data[line[1] - 1]
  local win = window.getoldwin()

  api.nvim_set_current_win(win)
  api.nvim_command('e ' .. data['path'])
  if data.line_nr then
    api.nvim_win_set_cursor(win, {data.line_nr, 0})
    api.nvim_command('normal! zz')
  end
end

local function quit()
  if loop.is_working() then
    loop.close(window.close)
  else
    window.close()
  end
end

local function stop()
  loop.close(function()
    local status = 'Match count: ' .. parser.match_count .. ' in ' .. parser.files_count .. ' files - Stopped!'
    window.set({ status }, 0, 1)
    window.color('SuperFindRed', 0, 0, -1)
  end)
end

local function sf(args)
  local args = parse_args(args)

  clock = os.clock()
  window.open_or_focus()

  window.set_mapping('<cr>', 'enter()')
  window.set_mapping('q', 'quit()')
  window.set_mapping('<c-c>', 'stop()')

  parser = Parser:new()

  cmd_args = {
    args['pattern'],
    '-iPn',
    '--max-columns=500',
    '-C=3',
    '--json'
  }
  if args['path'] then table.insert(cmd_args, args['path']) end

  loop.call('rg', cmd_args, onread, onexit)
end

return {
  sf = sf,
  enter = enter,
  quit = quit,
  stop = stop
}
