local api = vim.api
local buf, old_win, win
local namespace = api.nvim_create_namespace('SuperFind')

local function open()
  old_win = api.nvim_get_current_win()
  buf = api.nvim_create_buf(false, true)
  api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
  api.nvim_buf_set_option(buf, 'filetype', 'sf')
  api.nvim_buf_set_name(buf, 'Super Find')

  local size = math.floor(api.nvim_win_get_width(0) / 3)
  size = math.max(size, 60)

  api.nvim_command('rightbelow ' .. size .. ' vnew')
  win = api.nvim_get_current_win()
  api.nvim_win_set_option(0, 'list', false)
  api.nvim_win_set_buf(0, buf)
  api.nvim_set_current_win(old_win)
end

local function append(arr)
  local last_line = api.nvim_buf_line_count(buf)
  api.nvim_buf_set_option(buf, 'modifiable', true)
  api.nvim_buf_set_lines(buf, -1, -1, true, arr)
  api.nvim_buf_set_option(buf, 'modifiable', false)
  return last_line
end

local function color(group, l, s, e)
  api.nvim_buf_add_highlight(buf, namespace, group, l, s, e)
end

local function clear_color()
  api.nvim_buf_clear_namespace(buf, namespace, 0, -1)
end

local function set(arr, s, e)
  api.nvim_buf_set_option(buf, 'modifiable', true)
  api.nvim_buf_set_lines(buf, s, e, true, arr)
  api.nvim_buf_set_option(buf, 'modifiable', false)
end

local function getbuf()
  return buf
end

local function clear()
  if getbuf() and vim.fn.bufwinnr(getbuf()) ~= -1 then
    api.nvim_buf_set_option(buf, 'modifiable', true)
    api.nvim_buf_set_lines(buf, 0, -1, true, {})
    api.nvim_buf_set_option(buf, 'modifiable', false)
  end
end

local function open_or_focus()
  clear()
  if getbuf() and vim.fn.bufwinnr(getbuf()) ~= -1 then
    api.nvim_set_current_win(win)
  else
    open()
  end
end

local function set_mapping(k, v)
  api.nvim_buf_set_keymap(buf, 'n', k, ':lua require"sf".'..v..'<cr>', {
    nowait = true, noremap = true, silent = true
  })
end

return {
  append = append,
  open = open,
  getbuf = getbuf,
  set = set,
  color = color,
  open_or_focus = open_or_focus,
  clear_color = clear_color,
  set_mapping = set_mapping
}
