local Parser = {}
Parser.__index = Parser

local window      = require 'lib/window'
local api         = vim.api
local json_decode = vim.fn.json_decode

local indent = 4

function Parser:new()
  local obj = {
    lines = {},
    data = {},
    files_count = 0,
    match_count = 0
  }
  setmetatable(obj, Parser)
  return obj
end

function Parser:merge(other)
  self.files_count = self.files_count + other.files_count
  self.match_count = self.match_count + other.match_count
  for _,v in pairs(other.data) do table.insert(self.data, v) end
end

function Parser:parse(data)
  pcall(function()
    for _, json in ipairs(data) do
      if string.len(json) > 0 then
        local line = json_decode(json)

        if     line['type'] == 'begin'   then self:begin(line)
        elseif line['type'] == 'match'   then self:match(line)
        elseif line['type'] == 'context' then self:context(line)
        end
      end
    end
  end)
end

function Parser:begin(line)
  table.insert(self.data, {
    type  = 'blank',
    text  = '',
    value = ''
  })
  table.insert(self.data, {
    type  = 'begin',
    text  = line['data']['path']['text'],
    value = line['data']['path']['text']
  })

  self.files_count = self.files_count + 1
end

local function parse_line(line)
  local value   = line['data']['lines']['text']:gsub('\n$', '')
  local line_nr = line['data']['line_number']

  if string.len(line_nr) < indent then
    line_nr = line_nr .. string.rep(' ', indent - string.len(line_nr))
  end
  local text = line_nr .. ' ' .. value
  return value, line_nr, text
end

function Parser:match(line)
  value, line_nr, text = parse_line(line)

  table.insert(self.data, {
    type = 'match',
    value = value,
    line_nr = line_nr,
    text = text,
    submatches = line['data']['submatches']
  })
  self.match_count = self.match_count + 1
end

function Parser:context(line)
  value, line_nr, text = parse_line(line)

  table.insert(self.data, {
    type = 'context',
    value = value,
    line_nr = line_nr,
    text = text
  })
end

function Parser:get_text()
  local arr = {}
  for _,v in ipairs(self.data) do table.insert(arr, v['text']) end
  return arr
end

function Parser:draw()
  last_line = window.append(self:get_text())

  for i, v in pairs(self.data) do
    local current_line = i + last_line - 1

    if v['type'] == 'begin' then
      window.color('Identifier', current_line, 0, -1)
    end

    if v['type'] == 'context' then
      window.color('Number', current_line, 0, indent)
    end

    if v['type'] == 'match' then
      window.color('Number', current_line, 0, indent)

      for _,v in ipairs(v['submatches']) do
        window.color(
          'SuperFindRed',
          current_line,
          v['start'] + indent + 1,
          v['end'] + indent + 1,
          indent
        )
      end
    end
  end
end

return Parser
