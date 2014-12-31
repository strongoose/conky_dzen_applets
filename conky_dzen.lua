-- Some functions for use in conky config files, designed to be used in
-- conjunction with dzen.
--
-- Most functions here operate on either a normal string or a conky object. This
-- is convenient because it means that we can chain multiple functions together,
-- e.g. colorise a number by processing the conky object, then pad that number
-- to a certain width.
--
-- In order to do this, we need a function that processes input that could be
-- either a string or an object, and returns the parsed object in the first case
-- and the string in the other.

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

-- We also need a function to join the others.

function conky_chain()
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
