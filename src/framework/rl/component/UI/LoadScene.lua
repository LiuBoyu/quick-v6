
----------------------------------------
-- 组件·UI·加载场景 LoadScene
----------------------------------------

return function(object, args)

    local component = { id = "UI.LoadScene" }

----------------------------------------
-- 组件依赖
----------------------------------------

    if not object:isComponent("UI.Scene") then object:addComponent("UI.Scene") end

----------------------------------------
-- 组件参数
----------------------------------------

    local args = args or {}

    local done = args.__done

----------------------------------------
-- 对象方法·场景
----------------------------------------

    function object:goto()
        if done then
            done()
        end
    end

    return component
end

