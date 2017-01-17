
----------------------------------------
-- 设计分辨率
----------------------------------------

DESIGN_SCREEN_WIDTH  = 960 -- 960 -> 720
DESIGN_SCREEN_HEIGHT = 540 -- 540 -> 540

----------------------------------------
-- 框架初始化
----------------------------------------

require("framework.rl.init")

----------------------------------------
-- 全局配置
----------------------------------------

require(PROJNS .. ".config.Font")
require(PROJNS .. ".config.Text")

----------------------------------------
-- 全局配置
----------------------------------------

G = G or {}

----------------------------------------
-- 全局配置
----------------------------------------

G.Config = G.Config or {}

G.Config.App     = { Id      = APP_ID,
                     Name    = APP_NAME,
                     Code    = APP_CODE,
                     Product = APP_PRODUCT,
                     Channel = APP_CHANNEL,
                     Version = APP_VERSION,
                     Build   = APP_BUILD }

G.Config.Sqlite  = { FilePath = PROJ_DOC_PATH,
                     FileName = PROJNS .. ".db" }

G.Config.Http    = { Update = { BaseUrl = "http://s3.amazonaws.com/cocos2dx/samplesv6/update/",
                              },
                        API = { BaseUrl = "http://samplesv6.cocos2dx.org:8080/",
                              }}

G.Config.Url     = {}

G.Config.Cache   = { APIUserUidByFacebookGET = { storagePath = PROJ_DOC_PATH .. "caches/api/UserUidByFacebookGET/",
                                                      expires     = 60 * 60 * 24 * 30,
                                               },
                     APIUserGET              = { storagePath = PROJ_DOC_PATH .. "caches/api/UserGET/",
                                                      expires     = 60 * 60 * 1,
                                               },
                     UIUrlPic                = { storagePath = PROJ_DOC_PATH .. "caches/UI/UrlPic/",
                                                      expires     = 60 * 60 * 24 * 7,
                                               }}

G.Config.Update  = { UpdatePath = PROJ_DOC_PATH .. "update/",
                     RemotePath = PROJ_DOC_PATH .. "remote/" }

G.Config.Module  = require(PROJNS .. ".config.Module")
G.Config.IAP     = require(PROJNS .. ".config.IAP")

----------------------------------------
-- 全局配置
----------------------------------------

if DEBUG > 0 then
    require(PROJNS .. ".config.Debug")
    require(PROJNS .. "-debug.config")
end

log.info("Config: %s", G.Config)

----------------------------------------
-- FilePath
----------------------------------------

os.mkdir(G.Config.Update.UpdatePath)
os.mkdir(G.Config.Update.RemotePath)

----------------------------------------
-- Sqlite
----------------------------------------

G.SqliteClient = rl.SqliteClient.new(PROJ_DOC_PATH .. G.Config.Sqlite.FileName)

rl.G.SqliteClient = G.SqliteClient

----------------------------------------
-- Http
----------------------------------------

G.HttpClientAPI    = rl.HttpClient.new(G.Config.Http.API.BaseUrl)
G.HttpClient       = rl.HttpClient.new()

rl.G.HttpProxyClient = G.HttpClientAPI
rl.G.HttpProxyFilter = function(e) end

rl.G.UIUrlPicHttpClient = G.HttpClient
rl.G.UIUrlPicCache      = G.Config.Cache.UIUrlPic

----------------------------------------
-- App && Ctx
----------------------------------------

G.App = require(PROJNS .. ".app.App").new()
G.Ctx = require(PROJNS .. ".app.Ctx").new()
G.Net = require(PROJNS .. ".app.Net").new()

rl.G.App = G.App
rl.G.Ctx = G.Ctx
rl.G.Net = G.Net

----------------------------------------
-- System && Me
----------------------------------------

G.System = require(PROJNS .. ".app.System").new()
G.Me     = require(PROJNS .. ".app.Me").new()

----------------------------------------
-- 启动脚本
----------------------------------------

G.App:init()
G.Ctx:gotoMain()

