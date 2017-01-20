
----------------------------------------
-- 组件·调试框架 Ctx.Debug
----------------------------------------

return function(object)

    local component = { id = "Ctx.Debug" }

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

    function object:createSimpleModelUI(data, filters)
        local node = display.newNode()
        local keys = {}

        UI(node, { class = "SimpleModelUI" })
            :addComponent("EventProxy")

        local createKeyUI = function(k)
            local keyUI = display.newNode()

            local kUI = display.newText({ size = 16, font = "Default", color = cc.c3b(0,255,0) })
                :align(display.RIGHT_CENTER, 4, 0)
                :addTo(keyUI)
            local vUI = display.newText({ size = 16, font = "Default", color = cc.c3b(0,255,0) })
                :align(display.LEFT_CENTER, 4, 0)
                :addTo(keyUI)

            keyUI.kUI = kUI
            keyUI.vUI = vUI

            kUI:setText(k .. ": ")

            node:listenModelByInit(data, k, function(e)
                local k, v = e.k, e.v
                local filter

                if filters then
                    if not filter then
                        filter = filters[k]
                    end

                    if not filter then
                        for _k, _v in pairs(filters) do
                            if string.endswith(_k, ".*") then
                                if string.startswith(k, string.sub(_k, 1, -2)) then
                                    filter = filters[_k]
                                    break
                                end
                            end
                        end
                    end

                    if not filter then
                        filter = filters["*"]
                    end
                end

                if filter then
                    if type(filter) == "function" then
                        filter(k, v, keyUI)
                    else
                        if filter == "hide" then
                            if keyUI:isVisible() then
                                keyUI:hide()
                            end
                        end
                    end
                else
                    vUI:setText(tostring(v))
                end
            end)

            keys[k] = keyUI

            return keyUI
        end

        local titleUI = display.newText({ text = "<" .. data:getObjectName() .. ">", size = 16, font = "Default", color = cc.c3b(0,255,0) })
            :align(display.CENTER, 0, 0)
            :addTo(node)

        local keysUI = display.newNode()
            :addTo(node)

        UI:Button(titleUI, { mode = "fast" })

        titleUI:setOnTap(function()
            if keysUI:isVisible() then
                keysUI:hide()
            else
                keysUI:show()
            end
        end)

        for k, v in pairs(data:getall()) do
            local keyUI = createKeyUI(k)
                :addTo(keysUI)
        end

        function node:reloadUI()
            local t = {}

            for k, v in pairs(keys) do
                if keys[k]:isVisible() then
                    t[#t+1] = k
                end
            end

            table.sort(t)

            for i, k in ipairs(t) do
                local v = keys[k]

                v:pos(0, -i * 14 - 4)
            end
        end

        node:reloadUI()

        local simplemodel = data:getComponent("SimpleModel")

        simplemodel:setOnSet(function(e)
            local k = e.k
            local v = e.v

            if keys[k] then
                return
            end

            local keyUI = createKeyUI(k)
                :addTo(keysUI)

            node:reloadUI()
        end)

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

