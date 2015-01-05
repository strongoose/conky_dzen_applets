-- helpers.lua
--
-- This file contains some miscellaneous helper functions

function split(input, seperators)
  -- Return table of words in input string seperated by the characters
  -- in seperators
  pattern = "[^"..seperators.."]+"
  t = {}
  for word in input:gmatch(pattern) do
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

function char_iter(str)
  local i = 0
  local n = string.len(str)
  return function ()
           i = i + 1
           if i <= n then return string.sub(str, i, i) end
         end
end

function string_to_table(input)
  -- Note: keys may not have leading whitespace, nor may values have trailing
  -- whitespace.
  format_err = "string must be in format {key1=value1, key2=value2, ...}"
  t = {}
  state = "start"

  for char in char_iter(input) do
    -- if_escaped
    -- if we are not currently escaped, and the current character is a
    -- backslash, set escaped = true and skip processing
    if not escaped and char == '\\' then
        escaped = true
    else

      -- if_state
      if state == "start" then
        if char == '{' then
          state = "key"
          key = ''
        elseif string.find(char, '%s') then
        else
          error(format_err)
        end
  
      elseif state == 'key' then
        if char ~= '=' or escaped then
          key = key..char
        else
          state = "value"
          value = ''
        end
  
      elseif state == "value" then
        if char == '}' and not escaped then
          t[key] = value
          state = "done"
        elseif char ~= ',' or escaped then
          value = value..char
        else
          t[key] = value
          state = "next"
        end
  
      elseif state == "next" then
        if string.find(char, '%s') then
        else
          state = 'key'
          key = char
        end
      end --end if_state
      
      escaped = false
    end --end if_escaped
  end
  return t
end
