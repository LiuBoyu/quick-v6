
----------------------------------------
-- 组件·Ctx Ctx.Init
----------------------------------------

return function(object)

    local component = { id = "Ctx.Init" }

----------------------------------------
-- 组件依赖
----------------------------------------

    if not object:isComponent("UI.Ctx") then object:addComponent("UI.Ctx", { ModuleConfig = G.Config.Module }) end

    if DEBUG > 0 then
        if not object:isComponent("Ctx.Debug") then object:addComponent("Ctx.Debug") end
    end

----------------------------------------
-- 组件方法·事件回调
----------------------------------------

    G.CtxOnInitGotoBySceneName = function()
        G.System:set("Ctx.SceneName", G.Ctx:getSceneName())
    end

    G.CtxOnGotoByUIScene = function()
        local sceneObject = G.Ctx:getSceneObject()
        local sceneName   = G.Ctx:getSceneName()

        sceneObject:setKeypadEnabled(true)
        sceneObject:addNodeEventListener(cc.KEYPAD_EVENT, function (event) if G.Ctx:isBusy() then return end

            if event.key == "back"
            or event.key == "menu" then
                local dialog = sceneObject:getComponent("UI.Scene"):getDialog()

                dialog.ref = dialog.ref or {}

                local ok

                for k, v in pairs(dialog.ref) do
                    v:close()
                    ok = true
                end

                if ok then
                    return
                end
            end

            if event.key == "back" then
                if sceneObject.onBack then
                    sceneObject:onBack()
                end
            end
            if event.key == "menu" then
                if sceneObject.onMenu then
                    sceneObject:onMenu()
                end
            end

        end)
    end

----------------------------------------
-- 组件方法·事件回调
----------------------------------------

    object:setOnInitGoto(function()
        G.CtxOnInitGotoBySceneName()
    end)
    object:setOnGoto(function()
        if DEBUG > 0 then
            G.CtxOnInitByUIDebugScene()
            G.CtxOnGotoByUIDebugScene()
        end
        G.CtxOnGotoByUIScene()
    end)
    object:setOnExit(function()
        if DEBUG > 0 then
            G.CtxOnExitByUIDebugScene()
        end
    end)

    object:setOnInitPush(function()
    end)
    object:setOnPush(function()
        if DEBUG > 0 then
            G.CtxOnInitByUIDebugScene()
            G.CtxOnPushByUIDebugScene()
        end
    end)
    object:setOnBack(function()
        if DEBUG > 0 then
            G.CtxOnBackByUIDebugScene()
        end
    end)

----------------------------------------
-- 对象方法·工厂
----------------------------------------

    function object:createDialog(name, ...)
        return self:create("dialog." .. name, ...)
    end

    function object:createEntity(name, ...)
        return self:create("entity." .. name, ...)
    end

    function object:createUI(name, ...)
        return self:create("ui." .. name, ...)
    end

    return component
end

