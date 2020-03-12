local modes = {
  f = 'f'
}

-- based on https://stackoverflow.com/questions/28664139/lua-split-string-into-words-unless-quoted

local function parse(text)
  local result = {}
  local e = 0
  while true do
    local b = e+1
    b = text:find("%S",b)
    if b==nil then break end
    if text:sub(b,b)=="'" then
      e = text:find("'",b+1)
      b = b+1
    elseif text:sub(b,b)=='"' then
      e = text:find('"',b+1)
      b = b+1
    else
      e = text:find("%s",b+1)
    end
    if e==nil then e=#text+1 end
    table.insert(result, text:sub(b,e-1))
  end
  return result
end


local function parse_args(cmd)
  local args = parse(cmd)
  local pattern, next, mode, path
  local result = {}

  result['pattern'] = table.remove(args, 1)
  next = table.remove(args, 1)

  if not next then return result end

  mode = modes[next]

  if not mode then
    result['path'] = next
    return result
  end

  result['mode'] = mode
  result['path'] = table.remove(args, 1)
  return result
end

return {
  parse_args = parse_args
}
