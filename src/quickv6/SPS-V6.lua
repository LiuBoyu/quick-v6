
----------------------------------------
-- 编译参数
----------------------------------------

DEBUG     = DEBUG     or 0
DEBUG_LOG = DEBUG_LOG or 1

----------------------------------------
-- 应用配置
----------------------------------------

APP_ID      = "org.cocos2dx.quickv6"

APP_NAME    = "quickv6"
APP_CODE    = "SPS-V6"

APP_PRODUCT = "SPS"
APP_CHANNEL = "V6"

APP_VERSION = "0.1"
APP_BUILD   = 1

----------------------------------------
-- 错误处理
----------------------------------------

__G__TRACKBACK__ = function(msg)
    local msg = debug.traceback(tostring(msg), 2)

    print("----------------------------------------")
    print(msg)
    print("----------------------------------------")

    G.App:reportError(msg)
end

----------------------------------------
-- 启动函数
----------------------------------------

xpcall(function() require(PROJNS .. ".app.Init") end, __G__TRACKBACK__)

