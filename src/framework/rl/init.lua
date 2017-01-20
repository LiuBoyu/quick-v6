
require("framework.rl.functions")

-- platform

PLATFORM_IOS     = cc.Application:getInstance():getTargetPlatform() == 4 or     -- cc.PLATFORM_OS_IPHONE
                   cc.Application:getInstance():getTargetPlatform() == 5        -- cc.PLATFORM_OS_IPAD
PLATFORM_ANDROID = cc.Application:getInstance():getTargetPlatform() == 3        -- cc.PLATFORM_OS_ANDROID
PLATFORM_UNKNOWN = not (PLATFORM_IOS or PLATFORM_ANDROID)

-- 分辨率适配

local DESIGN_SCREEN_WIDTH  = DESIGN_SCREEN_WIDTH  or 1280
local DESIGN_SCREEN_HEIGHT = DESIGN_SCREEN_HEIGHT or  720
local DESIGN_SCREEN_RATIO  = DESIGN_SCREEN_WIDTH / DESIGN_SCREEN_HEIGHT

local DEVICE_SCREEN_WIDTH  = cc.Director:getInstance():getOpenGLView():getFrameSize().width
local DEVICE_SCREEN_HEIGHT = cc.Director:getInstance():getOpenGLView():getFrameSize().height
local DEVICE_SCREEN_RATIO  = DEVICE_SCREEN_WIDTH / DEVICE_SCREEN_HEIGHT

if DEVICE_SCREEN_RATIO < DESIGN_SCREEN_RATIO then
        CONFIG_SCREEN_WIDTH     = DESIGN_SCREEN_HEIGHT * DEVICE_SCREEN_RATIO
        CONFIG_SCREEN_HEIGHT    = DESIGN_SCREEN_HEIGHT
else
        CONFIG_SCREEN_WIDTH     = DESIGN_SCREEN_WIDTH
        CONFIG_SCREEN_HEIGHT    = DESIGN_SCREEN_WIDTH / DEVICE_SCREEN_RATIO
end

-- global

print("================================")
print("        LOAD FRAMEWORK          ")
print("================================")

debug.outputENV()

function requireByNS(filename)
    if string.startswith(filename, ".") then
        return require(APP_NS .. filename)
    else
        return require(filename)
    end
end

-- global

rl   = {}
rl.G = {}

-- rl.G.App
-- rl.G.Ctx

-- rl.G.Font
-- rl.G.Text

-- rl.G.HttpProxyClient
-- rl.G.HttpProxyFilter

-- rl.G.WSProxyClient
-- rl.G.WSProxyFilter

-- rl.G.SFProxyClient
-- rl.G.SFProxyFilter

-- rl.G.SqliteClient

-- rl.G.UIUrlPicHttpClient
-- rl.G.UIUrlPicHttpFilter
-- rl.G.UIUrlPicCache

-- rl.G.UIDebugSceneOnGotoBack

rl.COMPONENTS = {}
rl.OBJECTS    = {}

rl.class            = require("framework.rl.class")
rl.log              = require("framework.rl.log")

rl.ObjectFactory    = require("framework.rl.ObjectFactory")
rl.Component        = require("framework.rl.Component")
rl.Cache            = require("framework.rl.Cache")
rl.UI               = require("framework.rl.UI")

if CC_USE_CURL      then
rl.HttpClient       = require("framework.rl.HttpClient")
end

if CC_USE_WEBSOCKET then
rl.WSProtocol       = require("framework.rl.WSProtocol")
rl.WSClient         = require("framework.rl.WSClient")
rl.sprotoparser     = require("framework.rl.3rd.sprotoparser")
rl.sproto           = require("framework.rl.3rd.sproto")
end

if CC_USE_SFS2XAPI  then
rl.SFClient         = require("framework.rl.SFClient")
end

if CC_USE_SQLITE    then
rl.SqliteClient     = require("framework.rl.SqliteClient")
end

rl.ACTION           = require("framework.rl.util.ACTION")

-- components

rl.component = {}

rl.component.EventDispatcher = require("framework.rl.component.EventDispatcher")
rl.component.EventProxy      = require("framework.rl.component.EventProxy")
rl.component.HttpProxy       = require("framework.rl.component.HttpProxy")
rl.component.WSProxy         = require("framework.rl.component.WSProxy")
rl.component.SFProxy         = require("framework.rl.component.SFProxy")
rl.component.SimpleModel     = require("framework.rl.component.SimpleModel")
rl.component.SqliteModel     = require("framework.rl.component.SqliteModel")

-- components

rl.component.UI = {}

rl.component.UI.Button       = require("framework.rl.component.UI.Button")
rl.component.UI.DragDrop     = require("framework.rl.component.UI.DragDrop")
rl.component.UI.Dialog       = require("framework.rl.component.UI.Dialog")
rl.component.UI.UrlPic       = require("framework.rl.component.UI.UrlPic")
rl.component.UI.I18N         = require("framework.rl.component.UI.I18N")
rl.component.UI.Debug        = require("framework.rl.component.UI.Debug")

rl.component.UI.LongPoll     = require("framework.rl.component.UI.LongPoll")
rl.component.UI.Busy         = require("framework.rl.component.UI.Busy")

rl.component.UI.Ctx          = require("framework.rl.component.UI.Ctx")
rl.component.UI.Scene        = require("framework.rl.component.UI.Scene")

rl.component.UI.DebugScene   = require("framework.rl.component.UI.DebugScene")
rl.component.UI.LoadScene    = require("framework.rl.component.UI.LoadScene")

-- components

rl.component.SDK = {}

if PLATFORM_IOS     then
    rl.component.SDK.App         = require("framework.rl.component.SDK.App_IOS")
    rl.component.SDK.SFClient    = require("framework.rl.component.SDK.SFClient_IOS")
    rl.component.SDK.IAP         = require("framework.rl.component.SDK.IAP_IOS")
    rl.component.SDK.Facebook    = require("framework.rl.component.SDK.Facebook_IOS")
    rl.component.SDK.Share       = require("framework.rl.component.SDK.Share_IOS")
    rl.component.SDK.Vungle      = require("framework.rl.component.SDK.Vungle_IOS")
    rl.component.SDK.Testin      = require("framework.rl.component.SDK.Testin_IOS")
    rl.component.SDK.Dataeye     = require("framework.rl.component.SDK.Dataeye_IOS")
    rl.component.SDK.Umeng       = require("framework.rl.component.SDK.Umeng_IOS")
    rl.component.SDK.TalkingData = require("framework.rl.component.SDK.TalkingData_IOS")
    rl.component.SDK.Adjust      = require("framework.rl.component.SDK.Adjust_IOS")
end

if PLATFORM_ANDROID then
    rl.component.SDK.App         = require("framework.rl.component.SDK.App_Android")
    rl.component.SDK.SFClient    = require("framework.rl.component.SDK.SFClient_Android")
    rl.component.SDK.IAP         = require("framework.rl.component.SDK.IAP_Android")
    rl.component.SDK.Facebook    = require("framework.rl.component.SDK.Facebook_Android")
    rl.component.SDK.Share       = require("framework.rl.component.SDK.Share_Android")
    rl.component.SDK.Vungle      = require("framework.rl.component.SDK.Vungle_Android")
    rl.component.SDK.Testin      = require("framework.rl.component.SDK.Testin_Android")
    rl.component.SDK.Dataeye     = require("framework.rl.component.SDK.Dataeye_Android")
    rl.component.SDK.Umeng       = require("framework.rl.component.SDK.Umeng_Android")
    rl.component.SDK.TalkingData = require("framework.rl.component.SDK.TalkingData_Android")
    rl.component.SDK.Adjust      = require("framework.rl.component.SDK.Adjust_Android")
end

if PLATFORM_UNKNOWN then
    rl.component.SDK.App         = require("framework.rl.component.SDK.App_Unknown")
    rl.component.SDK.SFClient    = require("framework.rl.component.SDK.SFClient_IOS") -- Mac
    rl.component.SDK.IAP         = require("framework.rl.component.SDK.IAP_Unknown")
    rl.component.SDK.Facebook    = require("framework.rl.component.SDK.Facebook_Unknown")
    rl.component.SDK.Share       = require("framework.rl.component.SDK.Share_Unknown")
    rl.component.SDK.Vungle      = require("framework.rl.component.SDK.Vungle_Unknown")
    rl.component.SDK.Testin      = require("framework.rl.component.SDK.Testin_Unknown")
    rl.component.SDK.Dataeye     = require("framework.rl.component.SDK.Dataeye_Unknown")
    rl.component.SDK.Umeng       = require("framework.rl.component.SDK.Umeng_Unknown")
    rl.component.SDK.TalkingData = require("framework.rl.component.SDK.TalkingData_Unknown")
    rl.component.SDK.Adjust      = require("framework.rl.component.SDK.Adjust_Unknown")
end

-- components

rl.component.App = {}

rl.component.App.Init       = require("framework.rl.component.App.Init")
rl.component.App.Ads        = require("framework.rl.component.App.Ads")
rl.component.App.Analytics  = require("framework.rl.component.App.Analytics")
rl.component.App.IAP        = require("framework.rl.component.App.IAP")

rl.component.Ctx = {}

rl.component.Ctx.Init       = require("framework.rl.component.Ctx.Init")
rl.component.Ctx.Dialog     = require("framework.rl.component.Ctx.Dialog")
rl.component.Ctx.Debug      = require("framework.rl.component.Ctx.Debug")

-- components

rl.COMPONENT( "EventDispatcher", rl.component.EventDispatcher )    -- 事件分发
rl.COMPONENT( "EventProxy",      rl.component.EventProxy )         -- 事件代理
rl.COMPONENT( "HttpProxy",       rl.component.HttpProxy )          -- HTTP代理
rl.COMPONENT( "WSProxy",         rl.component.WSProxy )            -- WEBSOCKET代理
rl.COMPONENT( "SFProxy",         rl.component.SFProxy )            -- SFClient代理
rl.COMPONENT( "SimpleModel",     rl.component.SimpleModel )        -- 数据模型
rl.COMPONENT( "SqliteModel",     rl.component.SqliteModel )        -- 数据模型.Sqlite持久化

-- rl.COMPONENT( "StateMachine",    rl.component.StateMachine )       -- 状态机
-- rl.COMPONENT( "BehaviorTree",    rl.component.BehaviorTree )       -- 行为树

rl.COMPONENT( "UI.Button",       rl.component.UI.Button )          -- 触控按钮
rl.COMPONENT( "UI.DragDrop",     rl.component.UI.DragDrop )        -- 拖拽按钮
rl.COMPONENT( "UI.Dialog",       rl.component.UI.Dialog )          -- 对话窗体
rl.COMPONENT( "UI.UrlPic",       rl.component.UI.UrlPic )          -- 异步图片
rl.COMPONENT( "UI.I18N",         rl.component.UI.I18N )            -- 国际化
rl.COMPONENT( "UI.Debug",        rl.component.UI.Debug )           -- 开发调试

rl.COMPONENT( "UI.LongPoll",     rl.component.UI.LongPoll )        -- 智能轮询
rl.COMPONENT( "UI.Busy",         rl.component.UI.Busy )            -- 等待锁定

rl.COMPONENT( "UI.Ctx",          rl.component.UI.Ctx )             -- 上下文环境
rl.COMPONENT( "UI.Scene",        rl.component.UI.Scene )           -- 基础场景
rl.COMPONENT( "UI.LoadScene",    rl.component.UI.LoadScene )       -- 加载场景
rl.COMPONENT( "UI.DebugScene",   rl.component.UI.DebugScene )      -- 测试场景

rl.COMPONENT( "SDK.App",         rl.component.SDK.App )            -- SDK.App
rl.COMPONENT( "SDK.SFClient",    rl.component.SDK.SFClient )       -- SDK.SFClient
rl.COMPONENT( "SDK.IAP",         rl.component.SDK.IAP )            -- SDK.IAP

rl.COMPONENT( "SDK.Facebook",    rl.component.SDK.Facebook )       -- SDK.Facebook
rl.COMPONENT( "SDK.Share",       rl.component.SDK.Share )          -- SDK.Share
rl.COMPONENT( "SDK.Vungle",      rl.component.SDK.Vungle )         -- SDK.Vungle
rl.COMPONENT( "SDK.Testin",      rl.component.SDK.Testin )         -- SDK.Testin
rl.COMPONENT( "SDK.Dataeye",     rl.component.SDK.Dataeye )        -- SDK.Dataeye
rl.COMPONENT( "SDK.Umeng",       rl.component.SDK.Umeng )          -- SDK.Umeng
rl.COMPONENT( "SDK.TalkingData", rl.component.SDK.TalkingData )    -- SDK.TalkingData
rl.COMPONENT( "SDK.Adjust",      rl.component.SDK.Adjust )         -- SDK.Adjust

rl.COMPONENT( "App.Init",        rl.component.App.Init )           -- App.Init
rl.COMPONENT( "App.Ads",         rl.component.App.Ads )            -- App.Ads
rl.COMPONENT( "App.Analytics",   rl.component.App.Analytics )      -- App.Analytics
rl.COMPONENT( "App.IAP",         rl.component.App.IAP )            -- App.IAP

rl.COMPONENT( "Ctx.Init",        rl.component.Ctx.Init )           -- Ctx.Init
rl.COMPONENT( "Ctx.Dialog",      rl.component.Ctx.Dialog )         -- Ctx.Dialog
rl.COMPONENT( "Ctx.Debug",       rl.component.Ctx.Debug )          -- Ctx.Debug

-- components

Component = rl.Component
UI        = rl.UI

-- log

log       = rl.log

-- 垃圾收集

collectgarbage("setpause",    100)
collectgarbage("setstepmul", 5000)

-- quick v3

require("framework.init")
require("framework.rl.cocos.init")

-- ui

rl.ui = {}

rl.ui.AlertDialog = require("framework.rl.ui.AlertDialog")
rl.ui.BusyDialog  = require("framework.rl.ui.BusyDialog")

