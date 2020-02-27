local window = require 'lib/window'
local loop = require 'lib/loop'
local api = vim.api

local function process_line(line)
  local result = {}
  local pline = ''
  local head, tail
  local tline = line

  repeat
    head, tail = tline:match('^([^\27\155]*)[\27\155]%[0m[\27\155]%[1m[\27\155]%[32m(.*)')

    if tail then
      pline = pline .. head
      local start = string.len(pline)

      head, tline = tail:match('^([^\27\155]*)[\27\155]%[0m(.*)')
      pline = pline .. head
      local finish = string.len(pline)
      table.insert(result, {start = start, finish = finish})
    else
      pline = pline .. tline
    end
  until(not tail)

  return pline, result
end

local function onread(data)

  result = {}

  for i,v in ipairs(data) do

    v = v:gsub('[\27\155]%[0m[\27\155]%[31m', '')

    local item

    if v:match('^--$') then
      item = { matches = {} }
    else
      path, nr, line = v:match('^(.*)[\27\155]%[0m[:-][\27\155]%[0m(%d*)[\27\155]%[0m[-:](.*)')
      line, matches = process_line(line)
      item = {
        path = path,
        nr = nr,
        line = line,
        matches = matches
      }
    end

    table.insert(result, item)
    window.append({item['line']})

    local buf = window.getbuf()
    local last_line = api.nvim_buf_line_count(buf) - 1

    for i, v in ipairs(item['matches']) do
      api.nvim_buf_add_highlight(buf, -1, 'Identifier', last_line, v['start'], v['finish'])
    end
  end
end

local function sf(arg)
  window.open()
  loop.call('rg', {arg, '-iPn', '--no-heading', '--with-filename', '--max-columns=500', '-C=3', '--color=always', '--colors=path:fg:red', '--colors=line:none', '--colors=column:none', '--colors=match:fg:green'}, onread)
end

return {
  sf = sf
}
