local window = require 'lib/window'
local loop = require 'lib/loop'
local api = vim.api
local indent = 4
local match_count = 0
local files_count = 0

local function onread(data)
  local buf = window.getbuf()

  for i,v in ipairs(data) do

    if string.len(v) > 0 then
      pcall(function()
        local line = vim.fn.json_decode(v)

        if line['type'] == 'begin' then
          window.append({'', line['data']['path']['text']})
          local last_line = api.nvim_buf_line_count(buf) - 1
          api.nvim_buf_add_highlight(buf, -1, 'Identifier', last_line, 0, -1)
          files_count = files_count + 1
        end

        if line['type'] == 'match' then
          local line_nr = line['data']['line_number']
          if string.len(line_nr) < indent then
            line_nr = line_nr .. string.rep(' ', indent - string.len(line['data']['line_number']))
          end
          local str = line_nr .. ' ' .. line['data']['lines']['text']
          str = str:gsub('\n$', '')
          window.append({str})
          local last_line = api.nvim_buf_line_count(buf) - 1

          api.nvim_buf_add_highlight(buf, -1, 'Number', last_line, 0, string.len(tostring(line['data']['line_number'])))

          for i,v in ipairs(line['data']['submatches']) do
            api.nvim_buf_add_highlight(
              buf, -1, 'SuperFindRed', last_line, v['start'] + indent + 1, v['end'] + indent + 1
            )
          end

          match_count = match_count + 1
        end

        if line['type'] == 'context' then
          local line_nr = line['data']['line_number']
          if string.len(line_nr) < indent then
            line_nr = line_nr .. string.rep(' ', indent - string.len(line['data']['line_number']))
          end
          local str = line_nr .. ' ' .. line['data']['lines']['text']
          str = str:gsub('\n$', '')
          window.append({str})

          local last_line = api.nvim_buf_line_count(buf) - 1

          api.nvim_buf_add_highlight(buf, -1, 'Number', last_line, 0, string.len(tostring(line['data']['line_number'])))
        end
      end)
    end
    window.set({'Match count: ' .. match_count .. ' in ' .. files_count .. ' files'}, 0, 1)
  end
end

local function sf(arg)
  window.open()
  loop.call('rg', {arg, '-iPn', '--max-columns=500', '-C=3', '--json' }, onread)
end

return {
  sf = sf
}
