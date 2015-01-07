-- applets.lua
--
-- Some lua applets for use in conky config files, designed to be used in
-- conjunction with dzen.
-- 
-- functions in this file are essentially lua applets for conky, and can be
-- called in conky using the lua api (with lua_parse). These functions should
-- take as input relevant user-facing options, such as high and low thresholds
-- for battery colorising, icon locations, etc.
-- conky_colorised_battery(), for instance, outputs battery status and charge
-- percentage, padded to a fixed width, and colorised depending on battery
-- charge.
-- 
-- applets will probably use a number of worker functions, located in
-- 'workers.lua'. For example, conky_colorised_batmon() calls the worker
-- function colorise() on the battery value, then pads the battery string it
-- produces using pad(). Both of these functions return a table which keeps
-- formatting and values seperated; it is up to the applet to combine them.

require 'workers'
require 'helpers'

function conky_battery(args)
  if not args then
    args = {}
  else
    local arg_err = "Error converting argument to table: argument must be of"
                    .." form {key1=value1, key2=value2, ...})"
    args = assert(string_to_table(args), arg_err)
  end
  local low = tonumber(args.low) or 20
  local high = tonumber(args.high) or 20
  local lcol = args.lowcolor or '#FF0000'
  local hcol = args.highcolor or '#0000FF'
  local ccol = args.chargecolor or '#00FF00'
  local mcol = args.mcol -- no default
  -- 1 status indicator icon + 1 space + 3 digits
  -- = 5 chars
  local width = args.width or 5
  local ac_icon = args.ac_icon or "/home/dan/.xmonad/dzen2/ac_01.xbm"
  local no_ac_icon = args.no_ac_icon or "/home/dan/.xmonad/dzen2/arr_down.xbm"
  local ac_icon_col = args.ac_icon_color or nil
  local no_ac_icon_col = args.no_ac_icon_color or nil

  -- Check battery status
  local status, value = unpack(split(tostring(conky_parse("${battery_short}")), ' '))
  if value then
    local val_err = "Error processng value "..value.." into number."
    value = assert(value:match("(%d?%d?%d)%%"), val_err)
  end

  -- Deal with the less usual statuses.
  if status == 'F' then
    status = 'C'
    value = "100"
  elseif status == 'E' then
    status = 'D'
    value = "0"
  elseif status == 'U' then
    local leftpad, rightpad = fixed_width_pad('???', width, 'c')
    return leftpad .. '???' .. rightpad
  elseif status == 'N' then
    return dzen_fg('#FF0000').."Battery not present"..dzen_fg()
  elseif status ~= 'C' and status ~= 'D' then
    error("conky_colorised_barrery: something went wrong processing battery status\n"
          .."Expected 'D', 'C', 'F' or 'U', but got '"..status.."'")
  end

  local icon, icon_col = nil -- Set correct scope (local to function)
  if status == 'C' then
    status_name = 'charging'
    icon = ac_icon
    icon_col = ac_icon_col
  else
    status_name = 'discharging'
    icon = no_ac_icon
    icon_col = no_ac_icon_col
  end
  icon = dzen_ico(icon)
  icon_col = dzen_fg(icon_col)

  -- Now get the formatting for the number color.
  local valcol_l, valcol_r = nil
  if status == 'D' then
    valcol_l, valcol_r = dynamic_colorise(value, low, high, lcol, hcol)
  else
    valcol_l, valcol_r = dzen_fg(ccol), dzen_fg()
  end

  -- Get padding
  local value_width = string.len(value) + 2 -- Plus two characters for the icon and the space
  local lpad, rpad = fixed_width_pad(value_width, width)

  return lpad..icon_col..icon..' '..valcol_l..value..valcol_r..'%'..rpad
end

function conky_cpu(args)
  if not args then
    args = {}
  else
    local arg_err = "Error converting argument to table: argument must be of"
                    .." form {key1=value1, key2=value2, ...})"
    args = assert(string_to_table(args), arg_err)
  end
  local low = tonumber(args.low) or 15
  local high = tonumber(args.high) or 70
  local lcol = args.lowcolor or '#FF0000'
  local hcol = args.highcolor or '#0000FF'
  local mcol = args.mediumcolor or '#00FF00'
  -- 1 status indicator icon + 1 space + 3 digits
  -- = 5 chars
  local width = args.width or 5
  local ac_icon = args.ac_icon or "/home/dan/.xmonad/dzen2/ac_01.xbm"
  local no_ac_icon = args.no_ac_icon or "/home/dan/.xmonad/dzen2/arr_down.xbm"
  local ac_icon_col = args.ac_icon_color or nil
  local no_ac_icon_col = args.no_ac_icon_color or nil
end
