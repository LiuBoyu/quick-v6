
----------------
-- 字体
----------------

local M = {}

-- IOS 系统字体 (Arial, Courier)
if PLATFORM_IOS     then
    M["Default"]       = { font = "Arial" }
    M["Bold"]          = { font = "Arial@Bold" }
    M["Shadow"]        = { font = "Arial", shadow = { color = cc.c4b(0,0,0,255), offset = cc.size(2,-2), blurRadius = 0 } }
end

-- Android 系统字体 (normal, sans, serif, monospace)
if PLATFORM_ANDROID then
    M["Default"]       = { font = "normal" }
    M["Bold"]          = { font = "normal@Bold" }
    M["Shadow"]        = { font = "normal", shadow = { color = cc.c4b(0,0,0,255), offset = cc.size(2,-2), blurRadius = 0 } }
end

-- Mac 系统字体 (Arial, Courier)
if PLATFORM_UNKNOWN then
    M["Default"]       = { font = "Arial" }
    M["Bold"]          = { font = "Arial@Bold" }
    M["Shadow"]        = { font = "Arial", shadow = { color = cc.c4b(0,0,0,255), offset = cc.size(2,-2), blurRadius = 0 } }
end

return M

