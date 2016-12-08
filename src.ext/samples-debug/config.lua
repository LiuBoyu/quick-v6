
G.Debug = {}

----------------------------------------
-- 全局配置(Debug)
----------------------------------------

G.Config.Module["@@Main"]    = { searchPaths = { PROJNS .. "-debug.scene.000-Main"   }, goto = true, gotoName = "MainScene" }

G.Config.Module["@@Net"]     = { searchPaths = { "framework-debug.scene.005-Net"     }, goto = true, gotoName = "MainScene" }
G.Config.Module["@@Sdk"]     = { searchPaths = { "framework-debug.scene.006-Sdk"     }, goto = true, gotoName = "MainScene" }
G.Config.Module["@@Util"]    = { searchPaths = { "framework-debug.scene.009-Util"    }, goto = true, gotoName = "MainScene" }
G.Config.Module["@@Samples"] = { searchPaths = { "framework-debug.scene.010-Samples" }, goto = true, gotoName = "MainScene" }

----------------------------------------
-- 全局配置(Debug)
----------------------------------------

G.Debug.Helper = function()

    local sceneObject = G.Ctx:getSceneObject()
    local sceneName   = G.Ctx:getSceneName()

    require("framework-debug.helper.000-Common.Main")()

end

