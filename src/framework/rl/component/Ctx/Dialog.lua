
----------------------------------------
-- 组件·对话框 Ctx.Dialog
----------------------------------------

return function(object)

    local component = { id = "Ctx.Dialog" }

----------------------------------------
-- 对象方法·对话框
----------------------------------------

    function object:showDialog(name, ...)
        local dialog = G.Ctx:getSceneObject():getComponent("UI.Scene"):getDialog()

        local node = G.Ctx:createDialog(name, ...):addTo(dialog)

        node:addNodeEventListener(cc.NODE_EVENT, function(e)
            if e.name == "cleanup" then
                dialog.ref = dialog.ref or {}
                dialog.ref[node:getObjectId()] = nil
            end
        end)

        dialog.ref = dialog.ref or {}
        dialog.ref[node:getObjectId()] = node

        return node
    end

----------------------------------------
-- 对象方法·对话框
----------------------------------------

    function object:isBusy()
        local dialog = G.Ctx:getSceneObject():getComponent("UI.Scene"):getDialog()

        if dialog.busy then
            return true
        end
    end

    function object:showBusy(args)
        local dialog = G.Ctx:getSceneObject():getComponent("UI.Scene"):getDialog()

        if not dialog.busy then
            dialog.busy = rl.ui.BusyDialog.new(args):addTo(dialog, 9999)
        end

        dialog.busy.ct = dialog.busy.ct or 0
        dialog.busy.ct = dialog.busy.ct + 1

        return dialog.busy
    end

    function object:hideBusy()
        local dialog = G.Ctx:getSceneObject():getComponent("UI.Scene"):getDialog()

        if not dialog.busy then
            return
        end

        dialog.busy.ct = dialog.busy.ct or 0
        dialog.busy.ct = dialog.busy.ct - 1

        if dialog.busy.ct > 0 then
            return
        end

        dialog.busy:close()
        dialog.busy = nil
    end

    function object:performWithBusy(callback, args)
        local sceneObject = G.Ctx:getSceneObject()

        self:showBusy(args)

        callback(function()
            if not sceneObject.isObjectAlive then -- 判断场景是否切换
                return
            end

            self:hideBusy()
        end)
    end

----------------------------------------
-- 对象方法·对话框
----------------------------------------

    function object:showAlert(args)
        local alerts = G.Ctx:getSceneObject():getComponent("UI.Scene"):getAlerts()

        if type(args) == "string"
        or type(args) == "number" then
            args = { text = tostring(args) }
        end

        return rl.ui.AlertDialog.new(args):addTo(alerts)
    end

    return component
end

