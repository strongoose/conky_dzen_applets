-- Some functions for use in conky config files, designed to be used in
-- conjunction with dzen.
--
-- This file contains a few different types of functions, loosely speaking.
-- 
-- functions prefixed with 'conky_' are outward facing, and are essentially lua
-- applets for conky, These functions should take as input relevant user-facing
-- options, such as high and low thresholds for battery colorising, icon
-- locations, etc.
-- conky_colorised_batmon(), for instance, outputs a battery monitor which is
-- padded to a fixed width, changes color depending on battery charge, and uses
-- some nice, also colorised dzen icons to indicate status.
-- 
-- Unprefixed functions are generally going to be worker functions, which add
-- formatting to values provided by the applets. These functions will take a
-- value as their primary argument, plus relevant options, and should output a
-- length 3 table of left-formatting and right-formatting, formatting text which
-- goes on the right and left of the value.
-- For example, conkt_colorised_batmon(), from above, calls the worker function
-- colorise() on the battery value, then pads the battery string it produces
-- using pad(). Both of these functions return a table which keeps formatting
-- and values seperated; it is up to the applet to combine them.

function combine(lformat, value, rformat)
  return lformat .. value .. rformat
end

function pad(value, pad_width, alignment)
  -- Pad the output of a conky object using spaces, to fixed width pad_width.
  --
  -- alignment defaults to 'r'
  --
  -- alignment may equal 'r' (default), 'l', 'c' == 'cr', or 'cl' These denote
  -- four possible text alignments; right justified (padding on the left), left
  -- justified (padding on the right), centred or right-centred, where text is
  -- centred but favours the right (when exact centering is not possible), and
  -- left-centred, which is centred but favours left-alignment.
  
  side = side or 'l'
  if side ~= 'r' and side ~= 'l' and side ~= 'c' and side ~= 'cr' and side ~= 'cl' then
    return "Error: " .. side .. " is not a valid alignment."
  end

  pad_width = tonumber(pad_width)
  length = tonumber(string.len(value))

  if length > pad_width then
    return "Error: object longer than pad length."
  elseif length == pad_width then
    return value
  else
    pad = pad_width - length
    if side == 'r' then
      lpad = pad
      rpad = 0
    elseif side == 'l' then
      lpad = 0
      rpad = pad
    elseif side == 'c' or side == 'cr' then
      lpad = math.ceil(pad/2)
      rpad = pad - lpad
    else
      lpad = math.floor(pad/2)
      rpad = pad - lpad
    end
    return string.rep(" ", lpad) .. value .. string.rep(" ", rpad)
    --return {string.rep(" ", lpad), value, string.rep(" ", rpad)}
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
    return {"^fg(" .. color .. ")", value, "^fg()"}
  else
    return {"", value, ""}
  end
end
