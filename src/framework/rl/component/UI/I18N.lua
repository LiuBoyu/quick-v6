
----------------------------------------
-- 组件·UI·国际化 I18N
----------------------------------------

return function(object, args)

    local component = { id = "UI.I18N" }

----------------------------------------
-- 组件依赖
----------------------------------------

    if not object:isComponent("EventProxy") then object:addComponent("EventProxy") end

----------------------------------------
-- 组件参数
----------------------------------------

    local args = args or {}

    local onI18N = args.callback

----------------------------------------
-- 对象方法·国际化
----------------------------------------

    function object:setOnI18N(callback)
        onI18N = callback
    end

----------------------------------------
-- 对象方法·国际化
----------------------------------------

    local function setI18N(i18n)
        if object.setI18N then
            object:setI18N(i18n)
        end
        if onI18N then
            onI18N(i18n)
        end
    end

    object:listenEvent(rl.G.Ctx, "I18N", function(e)
        setI18N(e.language)
    end)

    setI18N(LANGUAGE)

    return component
end

