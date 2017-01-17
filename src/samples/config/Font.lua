
----------------------------------------
-- 字体
----------------------------------------

Font = {}

----------------
-- 系统
----------------

if PLATFORM_IOS     then
end

if PLATFORM_ANDROID then

    -- Android 系统字体 (normal, sans, serif, monospace)

    Font.Default       = { font = "normal" }
    Font.Bold          = { font = "normal@Bold" }
    Font.Shadow        = { font = "normal", shadow = { color = cc.c4b(0,0,0,255), offset = cc.size(2,-2), blurRadius = 0 } }

end

if PLATFORM_UNKNOWN then

    -- Mac 系统字体 (Arial, Courier)

    Font.Default       = { font = "Arial" }
    Font.Bold          = { font = "Arial@Bold" }
    Font.Shadow        = { font = "Arial", shadow = { color = cc.c4b(0,0,0,255), offset = cc.size(2,-2), blurRadius = 0 } }

end

