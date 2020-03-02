local api = vim.api
local loop = vim.loop

local handle, stdout, stderr, stdin

function call(cmd, args, onread, onexit)
  stdout = loop.new_pipe(false)
  stderr = loop.new_pipe(false)
  stdin  = loop.new_pipe(false)

  handle = vim.loop.spawn(cmd, {
    args = args,
    stdio = {stdin, stdout, stderr},
  }, vim.schedule_wrap(function()
    stdin:shutdown()
    stdout:read_stop()
    stderr:read_stop()
    stdout:close()
    stderr:close()
    handle:close()
    if onexit then
      onexit()
    end
  end))

  loop.read_start(stdout, vim.schedule_wrap(function(err, data)
    if err then error(err) end
    if data then onread(vim.split(data, "\n")) end
  end))
  loop.read_start(stderr, vim.schedule_wrap(function(err, data)
    if err then error(err) end
    if data then onread(vim.split(data, "\n")) end
  end))
end

return {
  call = call
}
