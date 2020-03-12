local window = require 'lib/window'
local loop = require 'lib/loop'
local Parser = require 'lib/parser'
local parse_args = require 'lib/args'.parse_args
local status = require 'lib/status'
local api = vim.api
local clock = 0
local parser
local last_line = ''

local function onread(data)
  -- last item is empty string or unfinished line
  -- so it is always safe to join it to next parsed chunk
  data[1] = last_line .. data[1]
  last_line = table.remove(data, #data)

  local l_parser = Parser.new()
  l_parser:parse(data)
  l_parser:draw()

  parser:merge(l_parser)
  status.statusline({
    files_count = parser.files_count,
    match_count = parser.match_count,
    clock = os.clock() - clock
  })
  status.firstline({
    files_count = parser.files_count,
    match_count = parser.match_count,
    clock = os.clock() - clock
  })
end

local function onexit()
  status.statusline({
    files_count = parser.files_count,
    match_count = parser.match_count,
    clock = os.clock() - clock,
    finished = true
  })
  status.firstline({
    files_count = parser.files_count,
    match_count = parser.match_count,
    clock = os.clock() - clock,
    finished = true
  })
  collectgarbage()
end

local function enter(mode)
  local line = api.nvim_win_get_cursor(0)
  local data = parser.data[line[1] - 1]
  if not data['path'] then return end
  local oldwin = window.getoldwin()
  local win = window.getwin()

  api.nvim_set_current_win(oldwin)

  if mode == 'i' then api.nvim_command('new ' .. data['path'])
  elseif mode == 's' then api.nvim_command('vnew ' .. data['path'])
  else
    api.nvim_command('e ' .. data['path'])
  end

  if data.line_nr then
    api.nvim_win_set_cursor(oldwin, {data.line_nr, 0})
    api.nvim_command('normal! zz')
  end

  if mode == 'p' then
    api.nvim_set_current_win(win)
    api.nvim_win_set_cursor(win, line)
  end

  if mode ~= 'p' then
    api.nvim_win_close(win, false)
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

local function sf(cmd)
  local args = parse_args(cmd)

  clock = os.clock()
  window.open_or_focus()

  window.set_mapping('<cr>', 'enter()')
  window.set_mapping('i', 'enter("i")')
  window.set_mapping('s', 'enter("s")')
  window.set_mapping('p', 'enter("p")')
  window.set_mapping('q', 'quit()')
  window.set_mapping('<c-c>', 'stop()')

  parser = Parser:new()

  cmd_args = {
    args['pattern'],
    '-iPn',
    '-C=3',
    '--json'
  }

  if args['mode'] == 'f' then
    table.insert(args['mode_args'], '-ptf')
    loop.single('fd', args['mode_args'], function(files)
      for i,v in ipairs(files) do
        if string.len(v) > 0  then table.insert(cmd_args, vim.trim(v)) end
      end
      loop.call('rg', cmd_args, onread, onexit)
    end)
  else
    if args['path'] then table.insert(cmd_args, args['path']) end
    loop.call('rg', cmd_args, onread, onexit)
  end
end

return {
  sf = sf,
  enter = enter,
  quit = quit,
  stop = stop
}
