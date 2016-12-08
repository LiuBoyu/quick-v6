
----------------------------------------
-- 组件·UI·场景 Scene
----------------------------------------

return function(object, args)

    local component = { id = "UI.Scene" }

----------------------------------------
-- 组件参数
----------------------------------------

    local args = args or {}

----------------------------------------
-- 对象方法·场景
----------------------------------------

    local dialog = display.newNode():addTo(object, 6000)
    local sysmsg = display.newNode():addTo(object, 8000)
    local editor = display.newNode():addTo(object, 9000)

    function component:getDialog()
        return dialog
    end

    function component:getSysMsg()
        return sysmsg
    end

    function component:getEditor()
        return editor
    end

    return component
end

