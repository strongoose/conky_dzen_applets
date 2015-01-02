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

function conky_colorised_battery(args)
  -- 1 status indicator icon + 1 space + 3 digits + 1 percentage sign
  -- = 6 chars
  if not args then
    args = {}
  end
  low = tonumber(args.low) or 20
  high = tonumber(args.high) or 20
  lcol = args.lowcolor or '#FF0000'
  hcol = args.highcolor or '#0000FF'
  ccol = args.chargecolor or '#00FF00'
  mcol = args.mcol -- no default
  width = args.width or 6
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
  status, value = unpack(split(conky_parse("${battery_short}")))
  if status == 'C' or status == 'D' then
    if status == 'C' then
      status_name = 'charging'
      icon = ac_icon
    else
      status_name = 'discharging'
      icon = no_ac_icon
    end
    value = assert(tonumber(value:match("(%d?%d?%d)%%")), "percentage"..
                   " expected with status "..status_name..", got "..value)
  elseif status == 'F' then
    value = 100
  elseif status == 'E' then
    value = 0
  elseif status == 'U' then
    return pad('???', width, 'c')
  elseif status == 'N' then
    return dzen_fg('#FF0000').."Battery not present"..dzen_fg()
  else
    error("conky_colorised_barrery: something went wrong processing battery status\n"
          .."Expected 'D', 'C', 'F' or 'U', but got '"..status.."'")
  end

  -- Now get the formatting for the number color.
  if status == 'D' then
    lformat, rformat = add_formatting(lformat, rformat,
                                      dynamic_colorise(value, low, high, lcol,
                                                       hcol))
  elseif status == 'C' then
    lformat, rformat = dzen_fg(ccol), dzen_fg()
  end
  
  if icon then
    value = dzen_ico(icon)..tostring(value)
    width = width + string.len(icon)
  end
  return lformat..pad(value, width)..rformat
end
