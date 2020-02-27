local window = require 'lib/window'
local api = vim.api
local loop = vim.loop
local handle, stdout, stderr

local function onread(err, data)
  if err then error(err) end
  if data then window.append(vim.split(data, '\n')) end
end

local function onexit(code, signal)
  p({code = code, signal = signal})
  stdin:shutdown()
  stdout:read_stop()
  stderr:read_stop()
  stdout:close()
  stderr:close()
  handle:close()
end

function call()
  stdout = loop.new_pipe(false)
  stderr = loop.new_pipe(false)
  stdin  = loop.new_pipe(false)

  handle, pid = vim.loop.spawn('rg', {
    args = { 'a' },
    stdio = {stdin, stdout, stderr},
  }, onexit)

  p(pid)

  loop.read_start(stdout, vim.schedule_wrap(function(err, data) onread(err, data) end))
  loop.read_start(stderr, vim.schedule_wrap(function(err, data) onread(err, data) end))
end

return {
  call = call
}
