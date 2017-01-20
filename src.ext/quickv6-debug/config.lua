
G.Debug = {}

----------------------------------------
-- 全局配置(Debug)
----------------------------------------

G.Config.Module["@@QuickV6"]            = { searchPaths = { "framework-debug.scene.QuickV6" }, goto = true, gotoName = "MainScene" }
G.Config.Module["@@QuickV6.Component"]  = { searchPaths = { "framework-debug.scene.QuickV6" }, goto = true, gotoName = "Component" }
G.Config.Module["@@QuickV6.SDK"]        = { searchPaths = { "framework-debug.scene.QuickV6" }, goto = true, gotoName = "SDK"       }
G.Config.Module["@@QuickV6.UI"]         = { searchPaths = { "framework-debug.scene.QuickV6" }, goto = true, gotoName = "UI"        }
G.Config.Module["@@QuickV6.Facebook"]   = { searchPaths = { "framework-debug.scene.QuickV6" }, goto = true, gotoName = "Facebook"  }
G.Config.Module["@@QuickV6.Utils"]      = { searchPaths = { "framework-debug.scene.QuickV6" }, goto = true, gotoName = "Utils"     }

G.Config.Module["@@Main"]               = { searchPaths = { PROJNS.."-debug.scene.StartUp"  }, goto = true, gotoName = "MainScene" }

----------------------------------------
-- 全局配置(Debug)
----------------------------------------

G.Debug.Helper = function()

    local sceneObject = G.Ctx:getSceneObject()
    local sceneName   = G.Ctx:getSceneName()

    require("framework-debug.helper.Common.Main")()

end

