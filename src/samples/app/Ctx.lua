
----------------------------------------
-- Ctx
----------------------------------------

local Ctx = class("Ctx")

----------------------------------------
-- 构建
----------------------------------------

function Ctx:ctor()
    Component(self)
        :addComponent("EventDispatcher")
        :addComponent("UI.Ctx", { ModuleConfig = G.Config.Module })
        :addComponent(PROJNS .. ".app.Ctx.Dialog")

    if DEBUG > 0 then
        self:addComponent(PROJNS .. ".app.Ctx.Debug")
    end

    self:setOnInitGoto(function()
        G.CtxOnInitGotoBySceneName()
    end)
    self:setOnGoto(function()
        if DEBUG > 0 then
            G.CtxOnInitByUIDebugScene()
            G.CtxOnGotoByUIDebugScene()
        end
        G.CtxOnGotoByUIScene()
    end)
    self:setOnExit(function()
        if DEBUG > 0 then
            G.CtxOnExitByUIDebugScene()
        end
    end)

    self:setOnInitPush(function()
    end)
    self:setOnPush(function()
        if DEBUG > 0 then
            G.CtxOnInitByUIDebugScene()
            G.CtxOnPushByUIDebugScene()
        end
    end)
    self:setOnBack(function()
        if DEBUG > 0 then
            G.CtxOnBackByUIDebugScene()
        end
    end)
end

----------------------------------------
-- 事件
----------------------------------------

G.CtxOnInitGotoBySceneName = function()
    G.System:set("Ctx.SceneName", G.Ctx:getSceneName())
end

local function isRealScene(name)
    if string.endswith(name, "(loading)") then
        return
    end
    if string.startswith(name, "@@") then
        return
    end
    return true
end

G.CtxOnGotoByUIScene = function()
    local sceneObject = G.Ctx:getSceneObject()
    local sceneName   = G.Ctx:getSceneName()

    if PLATFORM_ANDROID then
        if isRealScene(sceneName) then
            sceneObject:setKeypadEnabled(true)
            sceneObject:addNodeEventListener(cc.KEYPAD_EVENT, function (event)
                if event.key == "back" then
                    if G.Ctx:isShowBusyDialog() then
                        return
                    end

                    local dialog = sceneObject:getComponent("UI.Scene"):getDialog()
                    local ok

                    if dialog then
                        dialog.ref = dialog.ref or {}

                        for k, v in pairs(dialog.ref) do
                            v:close()
                            ok = true
                        end

                        if ok then
                            return
                        end
                    end

                    if sceneName ~= "Room" then
                        G.Ctx:showDialog("QuitGameDialog")
                    else
                        if sceneObject.onBack then
                            sceneObject:onBack()
                        end
                    end
                end
            end)
        end
    end
end

----------------------------------------
-- 工厂
----------------------------------------

function Ctx:createDialog(name, ...)
    return self:create("dialog." .. name, ...)
end

function Ctx:createEntity(name, ...)
    return self:create("entity." .. name, ...)
end

function Ctx:createUI(name, ...)
    return self:create("ui." .. name, ...)
end

----------------------------------------
-- Goto
----------------------------------------

function Ctx:gotoMain()
    return self:goto("Main")
end

return Ctx

