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

local function sf(arg)
  collectgarbage()
  window.open_or_focus()
  window.clear_color()
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
  sf = sf
}
