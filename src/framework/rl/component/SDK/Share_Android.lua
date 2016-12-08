
local log = rl.log("SDK.Share")

----------------------------------------
-- 组件·ShareSDK(Android)
----------------------------------------

return function(object, args)

    local component = { id = "SDK.Share(Android)" }

----------------------------------------
-- 组件参数
----------------------------------------

    local args = args or {}
    local ShareSDK = "com/havefunstudios/sdk/ShareSDK"

----------------------------------------
-- 对象方法
----------------------------------------

    function object:shareByShareSDK(args)
        log.debug("share: %s", args)

        local callback = function(state)
            return args.callback(tonumber(state))
        end

        local ok, ret = luaj.callStaticMethod(ShareSDK, "share", {
                            { image = args.image, text = args.text, title = args.title }, callback -- function(state) end -- 1 Success 2 Fail 3 Cancel
                        }, "(Ljava/util/HashMap;I)V")
        return ret
    end

    return component
end

