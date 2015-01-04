-- helpers.lua
--
-- This file contains some miscellaneous helper functions

function split(string)
  -- Return table of words in string.
  t = {}
  for word in string:gmatch("%S+") do
    table.insert(t, word)
  end
  return t
end

function add_formatting(lformat, rformat, newlformat, newrformat)
  lformat = lformat or ''
  rformat = rformat or ''
  newlformat = newlformat or ''
  newrformat = newrformat or ''
  return newlformat..lformat, rformat..newrformat
end

function dzen_fg(color)
  -- Wraps string with dzen foreground color syntax. With no arg, returns just
  -- ^fg(), which sets the color back to default.
  if color then
    return '^fg(\\'..color..')'
  else
    return '^fg()'
  end
end

function dzen_ico(path)
  return '^i('..path..')'
end
