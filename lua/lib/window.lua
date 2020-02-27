local api = vim.api
local buf

local function open()
  buf = api.nvim_create_buf(false, true)
  api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
  api.nvim_buf_set_option(buf, 'filetype', 'sf')
  api.nvim_buf_set_name(buf, 'Super Find')

  local size = math.floor(api.nvim_win_get_width(0) / 3)
  size = math.max(size, 60)

  api.nvim_command('rightbelow ' .. size .. ' vnew')
  api.nvim_win_set_option(0, 'list', false)
  api.nvim_win_set_buf(0, buf)
end

local function append(arr)
  api.nvim_buf_set_option(buf, 'modifiable', true)
  api.nvim_buf_set_lines(buf, -1, -1, true, arr)
  api.nvim_buf_set_option(buf, 'modifiable', false)
end

local function getbuf()
  return buf
end


return {
  append = append,
  open = open,
  getbuf = getbuf
}
