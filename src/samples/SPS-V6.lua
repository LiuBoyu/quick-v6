
----------------------------------------
-- 编译参数
----------------------------------------

DEBUG     = DEBUG     or 0
DEBUG_LOG = DEBUG_LOG or 1

----------------------------------------
-- 应用配置
----------------------------------------

APP_ID      = "org.cocos2dx.samplesv6"

APP_NAME    = "SPS-V6"
APP_CODE    = "SPS-V6"

APP_PRODUCT = "SPS"
APP_CHANNEL = "V6"

APP_VERSION = "0.1"
APP_BUILD   = 1

----------------------------------------
-- 启动函数
----------------------------------------

require(PROJNS .. ".app.Init")

