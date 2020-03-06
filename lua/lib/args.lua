local function parse_args(args)
  local pattern, tail, path

  local args = vim.trim(args)
  local char = args:match('^%s*(")') or args:match("^%s*(')")

  if char then
    pattern, tail = args:match(char..'(.-)'..char..'(.*)$')
    if tail and tail:len() > 0 then path = vim.trim(tail) end
  elseif args:match(' ') then
    pattern, path = unpack(vim.split(args, ' ', true))
  else
    pattern = args
  end

  return {
    pattern = pattern,
    path = path
  }
end

return {
  parse_args = parse_args
}
