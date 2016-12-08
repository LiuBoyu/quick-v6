
local log = rl.log("SDK.Share")

----------------------------------------
-- 组件·ShareSDK(IOS)
----------------------------------------

return function(object, args)

    local component = { id = "SDK.Share(IOS)" }

----------------------------------------
-- 组件参数
----------------------------------------

    local args = args or {}

----------------------------------------
-- 对象方法
----------------------------------------

    function object:shareByShareSDK(args)
        log.debug("share: %s", args)

        local ok, ret = luaoc.callStaticMethod("SDKApp", "shareByShareSDK", {
                            image       = args.image,
                            text        = args.text,
                            title       = args.title,
                            callback    = args.callback, -- function(state) end -- 1 Success 2 Fail 3 Cancel
                        })
        return ret
    end

    return component
end

