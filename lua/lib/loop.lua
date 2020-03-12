local api = vim.api
local loop = vim.loop

local handle, stdout, stderr, stdin, pid
local working = false

local function close(onexit)
  if not working then return end
  working = false
  stdout:read_stop()
  stderr:read_stop()
  loop.kill(pid, 9)
  stdin:shutdown()
  stdout:close()
  stderr:close()
  handle:close()
  if onexit then
    vim.schedule(onexit)
  end
end

local function on_exit(callback)
  return vim.schedule_wrap(function()
    working = false
    stdin:shutdown()
    stdout:read_stop()
    stderr:read_stop()
    stdout:close()
    stderr:close()
    handle:close()
    if callback then callback() end
  end)
end

local function on_read(callback)
  return vim.schedule_wrap(function(err, data)
    if err then error(err) end
    if data then callback(vim.split(data, "\n")) end
  end)
end

local function single(cmd, args, callback)
  local result = {}
  local single_handle

  local read_function = function(err, data)
    if err then error(err) end
    if data then vim.list_extend(result, vim.split(data, "\n")) end
  end

  local stdo = loop.new_pipe(false)
  local stde = loop.new_pipe(false)

  single_handle = vim.loop.spawn(cmd, {
    args = args,
    stdio = {stdo, stde},
  }, vim.schedule_wrap(function()
    stdo:read_stop()
    stde:read_stop()
    stdo:close()
    stde:close()
    single_handle:close()
    if callback then callback(result) end
  end))
  loop.read_start(stdo, read_function)
  loop.read_start(stde, read_function)
end

local function call(cmd, args, on_read_callback, on_exit_callback)
  stdout = loop.new_pipe(false)
  stderr = loop.new_pipe(false)
  stdin  = loop.new_pipe(false)
  working = true

  handle, pid = vim.loop.spawn(cmd, {
    args = args,
    stdio = {stdin, stdout, stderr},
  }, on_exit(on_exit_callback))

  read_function = on_read(on_read_callback)

  loop.read_start(stdout, read_function)
  loop.read_start(stderr, read_function)
end

local function is_working()
  return working
end

return {
  call = call,
  close = close,
  is_working = is_working,
  single = single
}
