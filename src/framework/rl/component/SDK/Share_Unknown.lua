
local log = rl.log("SDK.Share")

----------------------------------------
-- 组件·ShareSDK(Unknown)
----------------------------------------

return function(object, args)

    local component = { id = "SDK.Share(Unknown)" }

----------------------------------------
-- 组件参数
----------------------------------------

    local args = args or {}

----------------------------------------
-- 对象方法
----------------------------------------

    function object:shareByShareSDK(args)
        log.debug("share: %s", args)

        if args.callback then
            args.callback(1) -- 1 Success 2 Fail 3 Cancel
        end
    end

    return component
end

