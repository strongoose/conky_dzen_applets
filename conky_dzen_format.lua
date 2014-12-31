-- Some functions for use in conky config files, designed to be used in
-- conjunction with dzen.

function conky_format(object, functions)
  value = conky_parse("${" .. object .. "}")
  if not value then
    return "Error: first argument to conky_format must be a conky object."
  end
  function_strings = get_function_strings(functions)
  for _,string in pairs(function_strings) do
    f = loadstring("return "..string)
    call_return = dummy("one")
    load_return = f()
    lformat, rformat = unpack(f())
  end
  print(lformat .. rformat)
end

function get_function_strings(functions)
  function_strings_table = {}
  for i,list in pairs(functions) do
    list_length = table.maxn(list)
    function_string = list[1] .. "("
    for j = 2, list_length-1 do
      function_string = function_string .. list[j] .. ","
    end
    function_string = function_string .. list[list_length] .. ")"
    function_strings_table[i] = function_string
  end
  return function_strings_table
end

function render(object_or_string)
  -- Parse object_or_string as a conky object if it's enclosed in ${ ... }
  -- Otherwise, just return object_or_string
  len = string.len(object_or_string)
  front = string.sub(object_or_string, 1, 2)
  back = string.sub(object_or_string, len, len)
  if front == "${" and back == "}" then
    return conky_parse(object_or_string)
  else
    return object_or_string
  end
end

function conky_pad(object_or_string, pad_width, side)
  -- Pad the output of a conky object using spaces, to fixed width pad_width.
  --
  -- side defaults to 'l'
  --
  -- side may equal 'l' (default), 'r', 'b', 'br', for adding spaces to the
  -- to the left, to the right, to both sides with more padding on the left
  -- when uneven, or to both sides with more padding on the right when uneven,
  -- respectively.
  --
  side = side or 'l'
  if side ~= 'l' and side ~= 'r' and side ~= 'b' and side ~= 'br' then
    return "Error: " .. side .. " is not a valid argument."
  end

  pad_width = tonumber(pad_width)
  value = render(object_or_string)
  length = tonumber(string.len(value))

  if length > pad_width then
    return "Error: object longer than pad length."
  elseif length == pad_width then
    return value
  else
    pad = pad_width - length
    if side == 'l' then
      lpad = pad
      rpad = 0
    elseif side == 'r' then
      lpad = 0
      rpad = pad
    elseif side == 'b' then
      lpad = math.ceil(pad/2)
      rpad = pad - lpad
    else
      lpad = math.floor(pad/2)
      rpad = pad - lpad
    end
    return string.rep(" ", lpad) .. value .. string.rep(" ", rpad)
  end
end

function conky_num_color(object, threshold, color, low_or_high)
  -- Colorise numerical conky output; by default, below `threshold` output will
  -- be colored by `color`. Set low_or_high to 'high' to color above threshold.
  -- color must be a string composed of a hash followed by 6 digits (a hex color
  -- code).
  low_or_high = low_or_high or 'low'
  threshold = tonumber(threshold)

  if low_or_high == 'low' then
    low = true
  elseif low_or_high == 'high' then
    low = false
  else
    return "Error: " .. low_or_high .. " is not a valid argument."
  end

  object_string = "${" .. object .."}"
  value = conky_parse(object_string)
  if (low and (value <= threshold)) or (not low and (value >= threshold)) then
    return "^fg(" .. color .. ")" .. value .. "^fg()"
  else
    return value
  end
end
