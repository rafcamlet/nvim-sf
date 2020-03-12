local function find(arr, f, from)
  if not from then from = 1 end

  for i = from, #arr, 1 do
    if f(arr[i]) then return arr[i], i end
  end

  return nil
end

local function find_reverse(arr, f, from)
  if not from then from = #arr end

  for i = from, 1, -1 do
    if f(arr[i]) then return arr[i], i end
  end
  return nil
end

return {
  find = find,
  find_reverse = find_reverse
}
