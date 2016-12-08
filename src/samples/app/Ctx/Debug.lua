
----------------------------------------
-- 组件·行为逻辑 Ctx.Debug
----------------------------------------

return function(object)

    local component = { id = PROJNS .. ".app.Ctx.Debug" }

----------------------------------------
-- 对象方法·调试框架
----------------------------------------

    local function isTestScene(name)
        if string.startswith(name, "@@") then
            return true
        end
    end

    local function isRealScene(name)
        if string.endswith(name, "(loading)") then
            return
        end
        return true
    end

    G.CtxOnInitByUIDebugScene = function()
        local sceneObject = G.Ctx:getSceneObject()
        local sceneName   = G.Ctx:getSceneName()

        if isRealScene(sceneName) then
            if not sceneObject.isComponent
            or not sceneObject:isComponent("UI.Scene")      then
                G.Ctx:logERROR("场景: [%s] 没有添加[UI.Scene]组件", sceneName)
            end

            if not sceneObject.isComponent                  then UI:Scene(sceneObject)                     end
            if not sceneObject:isComponent("UI.DebugScene") then sceneObject:addComponent("UI.DebugScene") end

            if not isTestScene(sceneName) then
                if G.Debug.Helper then
                    G.Debug.Helper()
                end
            else
                sceneObject:SHOW("DEBUG")
            end
        end
    end

    G.CtxOnGotoByUIDebugScene = function()
        local scenePath = G.System:get("Debug.ScenePath") or {}
        local sceneName = scenePath[#scenePath] or "@@"

        if     isTestScene(sceneName) then
            scenePath[#scenePath+1] = G.Ctx:getRootSceneName()
        elseif isRealScene(sceneName) then
            scenePath[#scenePath]   = G.Ctx:getRootSceneName()
        end

        G.System:set("Debug.ScenePath", scenePath)
        G.System:flush()
    end

    G.CtxOnExitByUIDebugScene = function()
    end

    G.CtxOnPushByUIDebugScene = function()
    end

    G.CtxOnBackByUIDebugScene = function()
    end

----------------------------------------
-- 对象方法·调试框架
----------------------------------------

    rl.G.UIDebugSceneOnGotoBack = function()
        local scenePath = G.System:get("Debug.ScenePath") or {}
        if #scenePath > 1 then
            if G.Ctx:getRootSceneName() == G.Ctx:getSceneName() then

                table.remove(scenePath, #scenePath)

                G.System:set("Debug.ScenePath", scenePath)
                G.System:flush()
            end
        end
        return G.Ctx:goto(table.remove(scenePath, #scenePath))
    end

----------------------------------------
-- 对象方法·调试框架
----------------------------------------

    function object:createDebugModelUI(data, list)
        local node = display.newNode()
        node.label = {}

        UI(node, { class = "DebugModelUI" })
            :addComponent("EventProxy")

        local lbl = display.newText({ text = "<<" .. data:getObjectName() .. ">>", size = 12, font = Font.DEFAULT, color = cc.c3b(0,255,255) })
            :align(display.LEFT_BOTTOM, 0, #list * 10)
            :addTo(node)

        for i, k in pairs(list) do
            local lbl = display.newText({ size = 12, font = Font.DEFAULT, color = cc.c3b(0,255,255) })
                :align(display.LEFT_BOTTOM, 0, (#list - i) * 10)
                :addTo(node)

            node:listenModelByInit(data, k, function(e)
                lbl:setText(k .. ": " .. tostring(data:get(k)))
            end)

            node.label[k] = lbl
        end

        function node:reloadUI()
            for k, v in pairs(node.label) do
                v:setText(k .. ": " .. tostring(data:get(k)))
            end
        end

        return node
    end

----------------------------------------
-- 对象方法·调试框架
----------------------------------------

    function object:gotoMain()
        local scenePath = G.System:get("Debug.ScenePath") or {}
        if #scenePath > 0 then
            return G.Ctx:goto(table.remove(scenePath, #scenePath))
        else
            return G.Ctx:goto("@@Main")
        end
    end

    return component
end

