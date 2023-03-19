require 'mp'
require 'mp.msg'



copy_cmd = 'wl-copy'
paste_cmd = 'wl-paste'

local function divmod(a, b)
    return a / b, a % b
end

local function set_clipboard(text) 
    local pipe = io.popen(copy_cmd, "w")
    pipe:write(text)
    pipe:close()
    return true
end


local function get_clipboard() 
    local pipe = io.popen(paste_cmd, "r")
    local text = pipe:read()
    pipe:close()
    return text
end



local function copyTime()
    local time_pos = mp.get_property_number("time-pos")
    local minutes, remainder = divmod(time_pos, 60)
    local hours, minutes = divmod(minutes, 60)
    local seconds = math.floor(remainder)
    local milliseconds = math.floor((remainder - seconds) * 1000)
    local time = string.format("%02d:%02d:%02d.%03d", hours, minutes, seconds, milliseconds)
    if set_clipboard(time) then
        mp.osd_message(string.format("Copied to Clipboard: %s", time))
        mp.set_property_native("pause", true)
        mp.set_property_native("time-pos", time)
    else
        mp.osd_message("Failed to copy time to clipboard")
    end
end

mp.add_key_binding("Ctrl+c", "copyTime", copyTime)


local function pasteTime()
    local time = get_clipboard()
    if time then
        if mp.set_property_native("time-pos", time) then
            -- mp.set_property_native("pause", true)
            mp.osd_message(string.format("Pasted from Clipboard: %s", time))
        else
            mp.osd_message(string.format("Failed to go to time %s", time))
        end
    else
        mp.osd_message("Failed to paste from Clipboard")
    end
    -- mp.osd_message(time)
end

mp.add_key_binding("Ctrl+v", "pasteTime", pasteTime)
