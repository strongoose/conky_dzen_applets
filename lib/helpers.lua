-- helpers.lua
--
-- This file contains some miscellaneous helper functions

function split(input, seperators)
  -- Return table of words in input string seperated by the characters
  -- in seperators
  local pattern = "[^"..seperators.."]+"
  local t = {}
  for word in input:gmatch(pattern) do
    table.insert(t, word)
  end
  return t
end

function dzen_fg(color)
  -- Wraps string with dzen foreground color syntax. With no arg, returns just
  -- ^fg(), which sets the color back to default.
  local hex_color_pattern = '#' .. string.rep('[%dA-Fa-f]', 6)
  local string = "^fg()"
  if color then
    if color == color:match(hex_color_pattern) then
      string = '^fg(\\'..color..')'
    else
      error(color.." is not a valid hex string.")
    end
  end
  return string
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
  local format_err = "string must be in format {key1=value1, key2=value2, ...}"
  local t = {}
  local state = "start"
  local key, value = nil

  for char in char_iter(input) do
    -- if_escaped
    -- if we are not currently escaped, and the current character is a
    -- backslash, set escaped = true and skip processing
    --
    local escaped = false

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
    end --end if_escaped
  end --end for loop
  return t
end

function get_args(args)
  if not args then
    args = {}
  else
    local arg_err = "Error converting argument to table: argument must be of"
                    .." form {key1=value1, key2=value2, ...})"
    args = assert(string_to_table(args), arg_err)
  end
  return args
end
