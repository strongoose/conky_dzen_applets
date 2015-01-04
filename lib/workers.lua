-- workers.lua
--
-- These functions are not user-facing: they take values, not conky objects, and
-- return the left and right formatting to be applied to those values (as two
-- return values, not as a table. NB: they do not return the value itself!
-- Modifying values, when necessary, is the job of the main applet function.
--  
--  If there is no work to be done these functions should return nil

require 'helpers'

function fixed_width_pad(length, pad_width, alignment)
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
    error("pad: '" .. side .. "' is not a valid alignment")
  end

  if length > pad_width then
    error("pad: value to be padded is longer than pad_width")
  else
    pad = pad_width - length
    if side == 'l' then
      lpad = pad
      rpad = 0
    elseif side == 'r' then
      lpad = 0
      rpad = pad
    elseif side == 'cl' then
      lpad = math.ceil(pad/2)
      rpad = pad - lpad
    else
      lpad = math.floor(pad/2)
      rpad = pad - lpad
    end
    return string.rep(" ", lpad), string.rep(" ", rpad)
  end
end

function dynamic_colorise(value, low, high, lowcol, highcol)
  -- Dynamically colorise numerical conky output; if value is below low or above
  -- high, apply lowcol or highcol, respectively. color must be a string
  -- composed of a hash followed by 6 digits (a hex color code).

  value = tonumber(value)

  if not (low or high) then
    return None
  end

  if value <= low then
    col = lowcol
  elseif value >= high then
    col = highcol
  end

  if col then
    return dzen_fg(col), dzen_fg()
  else
    return None
  end
end
