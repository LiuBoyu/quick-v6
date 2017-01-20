
-- 项目名称
PROJNS = "samples"
PROJID = "SPS-V6"

-- 项目路径
PROJ_DOC_PATH = cc.FileUtils:getInstance():getWritablePath() .. string.format("var/")

-- 脚本路径
package.path = PROJ_DOC_PATH .. "update/src/?.lua"
                             .. ';src/?.lua'

-- 资源路径
cc.FileUtils:getInstance():addSearchPath("zip/")
cc.FileUtils:getInstance():addSearchPath(PROJ_DOC_PATH .. "update/zip/")
cc.FileUtils:getInstance():addSearchPath("res/")
cc.FileUtils:getInstance():addSearchPath(PROJ_DOC_PATH .. "update/res/")
cc.FileUtils:getInstance():setPopupNotify(false)

-- 脚本加载
cc.LuaLoadChunksFromZIP(cc.FileUtils:getInstance():fullPathForFilename(  "framework.zip" ))
cc.LuaLoadChunksFromZIP(cc.FileUtils:getInstance():fullPathForFilename( PROJNS .. ".zip" ))

-- 启动函数
require(PROJNS .. "." .. PROJID)

