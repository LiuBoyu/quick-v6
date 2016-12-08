
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

    Font.DEFAULT       = { font = "normal" }

    Font.Default       = { font = "normal" }
    Font.DefaultShadow = { font = "normal", shadow = { color = cc.c4b(0,0,0,255), offset = cc.size(2,-2), blurRadius = 0 } }
    Font.SysMsg        = { font = "normal@Bold" }

end

if PLATFORM_UNKNOWN then

    -- Mac 系统字体 (Arial, Courier)

    Font.DEFAULT       = { font = "Arial" }

    Font.Default       = { font = "Arial" }
    Font.DefaultShadow = { font = "Arial", shadow = { color = cc.c4b(0,0,0,255), offset = cc.size(2,-2), blurRadius = 0 } }
    Font.SysMsg        = { font = "Arial@Bold" }

end

