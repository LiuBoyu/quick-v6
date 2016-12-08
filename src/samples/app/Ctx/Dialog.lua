
----------------------------------------
-- 组件·行为逻辑 Ctx.Dialog
----------------------------------------

return function(object)

    local component = { id = PROJNS .. ".app.Ctx.Dialog" }

----------------------------------------
-- 对象方法·对话框
----------------------------------------

    function object:showDialog(name, ...)
        local dialog = G.Ctx:getSceneObject():getComponent("UI.Scene"):getDialog()

        if not dialog then
            return
        end

        local object = G.Ctx:createDialog(name, ...):addTo(dialog)

        object:addNodeEventListener(cc.NODE_EVENT, function(e)
            if e.name == "cleanup" then
                dialog.ref = dialog.ref or {}
                dialog.ref[object:getObjectId()] = nil
            end
        end)

        dialog.ref = dialog.ref or {}
        dialog.ref[object:getObjectId()] = object

        return object
    end

----------------------------------------
-- 对象方法·对话框
----------------------------------------

    function object:isShowBusyDialog()
        local dialog = G.Ctx:getSceneObject():getComponent("UI.Scene"):getDialog()

        if not dialog then
            return
        end

        local busyDlg = dialog.busyDlg

        if not busyDlg then
            return
        end

        return (busyDlg.ct or 0) > 0
    end

    function object:showBusyDialog(args)
        local dialog = G.Ctx:getSceneObject():getComponent("UI.Scene"):getDialog()

        if not dialog then
            return
        end

        local busyDlg = dialog.busyDlg

        if not busyDlg then
            busyDlg = G.Ctx:createDialog("BusyDialog", args):addTo(dialog, 9999)
            dialog.busyDlg = busyDlg
        end

        busyDlg.ct = busyDlg.ct or 0
        busyDlg.ct = busyDlg.ct + 1

        return busyDlg
    end

    function object:hideBusyDialog()
        local dialog = G.Ctx:getSceneObject():getComponent("UI.Scene"):getDialog()

        if not dialog then
            return
        end

        local busyDlg = dialog.busyDlg

        if not busyDlg then
            return
        end

        busyDlg.ct = busyDlg.ct or 0
        busyDlg.ct = busyDlg.ct - 1

        if busyDlg.ct < 1 then
            dialog.busyDlg:close()
            dialog.busyDlg = nil
        end
    end

    function object:performWithBusyDialog(callback, args)
        local sceneObject = G.Ctx:getSceneObject()
        self:showBusyDialog(args)
        callback(function()
            if sceneObject.isObjectAlive then -- 判断场景是否切换
                self:hideBusyDialog()
            end
        end)
    end

----------------------------------------
-- 对象方法·对话框
----------------------------------------

    function object:showSysMsg(data)
        local sysmsg = G.Ctx:getSceneObject():getComponent("UI.Scene"):getSysMsg()

        if not sysmsg then
            return
        end

        return G.Ctx:createDialog("SysMsgDialog", data):addTo(sysmsg)
    end

    return component
end

