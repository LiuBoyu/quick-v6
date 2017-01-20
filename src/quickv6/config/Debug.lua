
----------------------------------------
-- 调试
----------------------------------------

-- 调试信息
DEBUG_FPS = false
DEBUG_MEM = false

-- 调试开关
DEBUG_OFF_CACHE             = false

-- 调试SQL
DEBUG_LOG_SQL               = false

-- 调试HTTP
DEBUG_LOG_HTTP              = true
DEBUG_LOG_HTTP_URLS         = {
}

-- 调试WEBSOCKET
DEBUG_LOG_WEBSOCKET         = true
DEBUG_LOG_WEBSOCKET_URLS    = {
}

-- 调试SFCLIENT
DEBUG_LOG_SFS2XAPI          = true
DEBUG_LOG_SFS2XAPI_URLS     = {
}

-- 调试组件
DEBUG_LOG_COMPONENT         = false
DEBUG_LOG_OBJECTFACTORY     = false
DEBUG_LOG_EVENTDISPATCHER   = true
DEBUG_LOG_EVENTLISTENER     = false
DEBUG_LOG_SQLITEMODEL       = false
DEBUG_LOG_UI                = true
DEBUG_LOG_UICTX             = true
DEBUG_LOG_UIBUTTON          = false
DEBUG_LOG_UIDIALOG          = false
DEBUG_LOG_UILONGPOLL        = true
DEBUG_LOG_UIBUSY            = true

----------------------------------------
-- 日志 0.Error 1.Warn 2.Info 3.Debug
----------------------------------------

LOG = { ["*"] = 3 }

LOG["SqliteClient"]     = 3

LOG["HttpClient"]       = 3
LOG["WSClient"]         = 3
LOG["SFClient"]         = 3

LOG["SDK"]              = 3

LOG["App"]              = 3
LOG["Ctx"]              = 3
LOG["Net"]              = 3

LOG["System"]           = 3
LOG["Me"]               = 3

