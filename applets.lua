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
    args = assert(string_to_table(args), "Error converting argument to table:"
                                         .." argument must be of form {key1=value1"
                                         ..", key2=value2, ...})")
  end
  error(args.highcolor)
  low = tonumber(args.low) or 20
  high = tonumber(args.high) or 20
  lcol = args.lowcolor or '#FF0000'
  hcol = args.highcolor or '#0000FF'
  ccol = args.chargecolor or '#00FF00'
  mcol = args.mcol -- no default
  -- 1 status indicator icon + 1 space + 3 digits
  -- = 5 chars
  width = args.width or 5
  ac_icon = args.ac_icon or "/home/dan/.xmonad/dzen2/ac_01.xbm"
  no_ac_icon = args.no_ac_icon or "/home/dan/.xmonad/dzen2/arr_down.xbm"

  lformat, rformat = '', ''
  hex_color_pattern = '#' .. string.rep('[%dA-Fa-f]', 6)

  if lcol ~= string.match(lcol, hex_color_pattern) then
    error('conky_colorised_battery: ' .. lcol .. ' is not a valid hex color code')
  end
  if hcol ~= string.match(hcol, hex_color_pattern) then
    error('conky_colorised_battery: ' .. hcol .. ' is not a valid hex color code')
  end

  -- Check battery status
  status, value = unpack(split(tostring(conky_parse("${battery_short}")), ' '))
  if value then
    value = assert(value:match("(%d?%d?%d)%%"), "error extracting number from "
                                                ..value)
  end

  if status == 'F' then
    status = 'C'
    value = "100"
  elseif status == 'E' then
    status = 'D'
    value = "0"
  elseif status == 'U' then
    lformat, rformat = fixed_width_pad('???', width, 'c')
    return lformat .. '???' .. rformat
  elseif status == 'N' then
    return dzen_fg('#FF0000').."Battery not present"..dzen_fg()
  elseif status ~= 'C' and status ~= 'D' then
    error("conky_colorised_barrery: something went wrong processing battery status\n"
          .."Expected 'D', 'C', 'F' or 'U', but got '"..status.."'")
  end

  if status == 'C' then
    status_name = 'charging'
    icon = ac_icon
  else
    status_name = 'discharging'
    icon = no_ac_icon
  end
  icon = dzen_ico(icon)

  -- Now get the formatting for the number color.
  if status == 'D' then
    valcol_l, valcol_r = add_formatting(lformat, rformat,
                                        dynamic_colorise(value, low, high, lcol,
                                                         hcol))
  else
    valcol_l, valcol_r = add_formatting(lformat, rformat,
                                        dzen_fg(ccol), dzen_fg())
  end

  -- Get padding
  value_width = string.len(value) + 2 -- Plus two characters for the icon and the space
  lpad, rpad = add_formatting(lformat, rformat,
                              fixed_width_pad(value_width, width))

  --error(lpad..icon..' '..valcol_l..value..valcol_r..'%'..rpad)
  return lpad..icon..' '..valcol_l..value..valcol_r..'%'..rpad
end
