
----------------------------------------
-- 组件·UI·上下文环境 Ctx
----------------------------------------

return function(object, args)

    local component = { id = "UI.Ctx" }

----------------------------------------
-- 组件参数
----------------------------------------

    local args = args or {}

----------------------------------------
-- 对象方法·对象工厂
----------------------------------------

    local objectfactory = rl.ObjectFactory.new({})

    function object:createObject(name, ...)
        return objectfactory:createObject(name, ...)
    end
    object.create = object.createObject

    function object:require(name)
        return objectfactory:require(name)
    end

    function object:getObjectFactory()
        return objectfactory
    end

----------------------------------------
-- 对象方法·场景对象
----------------------------------------

    local currSceneObject
    local rootSceneObject

    function object:setSceneObject(sceneObject)
        currSceneObject = sceneObject
    end

    function object:getSceneObject()
        return currSceneObject
    end

    function object:setRootSceneObject(sceneObject)
        rootSceneObject = sceneObject
    end

    function object:getRootSceneObject()
        return rootSceneObject
    end

----------------------------------------
-- 对象方法·场景名称
----------------------------------------

    local currSceneName
    local rootSceneName

    function object:setSceneName(name)
        currSceneName = name
    end

    function object:getSceneName()
        return currSceneName
    end

    function object:setRootSceneName(name)
        rootSceneName = name
    end

    function object:getRootSceneName()
        return rootSceneName
    end

----------------------------------------
-- 对象方法·场景名称
----------------------------------------

    local prevSceneName

    function object:setPrevSceneName(name)
        prevSceneName = name
    end

    function object:getPrevSceneName()
        return prevSceneName
    end

----------------------------------------
-- 对象方法·场景回调
----------------------------------------

    local onLoad
    local onInitGoto
    local onGoto
    local onExit
    local onInitPush
    local onPush
    local onBack

    function object:setOnLoad(callback)
        onLoad = callback
    end

    function object:setOnInitGoto(callback)
        onInitGoto = callback
    end

    function object:setOnGoto(callback)
        onGoto = callback
    end

    function object:setOnExit(callback)
        onExit = callback
    end

    function object:setOnInitPush(callback)
        onInitPush = callback
    end

    function object:setOnPush(callback)
        onPush = callback
    end

    function object:setOnBack(callback)
        onBack = callback
    end

----------------------------------------
-- 对象方法·场景 (内部)
----------------------------------------

    local function cleanup()
        if CC_USE_CCSTUDIO then
        -- 清理动画
        ccs.ArmatureDataManager:destroyInstance()
        end
        -- 清理帧
        cc.SpriteFrameCache:getInstance():removeSpriteFrames()
        -- 清理材质
        cc.Director:getInstance():getTextureCache():removeAllTextures()
        -- 垃圾收集
        collectgarbage("collect")
    end

    local function replace(scene)
        if cc.Director:getInstance():getRunningScene() then
            cc.Director:getInstance():replaceScene(scene)
        else
            cc.Director:getInstance():runWithScene(scene)
        end
    end

----------------------------------------
-- 对象方法·场景 (内部)
----------------------------------------

    local function load(name, cfg, done)
        if cfg.load then
            cleanup()

            local scene = objectfactory:createClassInstance(cfg.loadName or "LoadScene")

            object:setRootSceneObject(scene)
            object:setSceneObject(scene)
            object:setRootSceneName(string.format("%s(loading)", name))
            object:setSceneName(string.format("%s(loading)", name))

            scene:ctor({ __name = name, __cfg = cfg, __done = done })
            replace(scene)

            if DEBUG_LOG_UICTX then
                object:logDEBUG("LOAD场景: [%s]", name)
            end

            if onLoad then
                onLoad()
            end
        else
            done()
        end
    end

    local function goto(name, cfg, args)
        load(name, cfg, function()
            cleanup()

            local scene = objectfactory:createClassInstance(cfg.gotoName or "MainScene")

            object:setRootSceneObject(scene)
            object:setSceneObject(scene)
            object:setRootSceneName(name)
            object:setSceneName(name)

            if DEBUG_LOG_UICTX then
                object:logDEBUG("INIT场景: [%s]", name)
            end

            if onInitGoto then
                onInitGoto()
            end

            scene:ctor(unpack(args))
            replace(scene)

            if DEBUG_LOG_UICTX then
                object:logDEBUG("GOTO场景: [%s]", name)
            end

            if onGoto then
                onGoto()
            end
        end)
    end

    local isPushed = false

    local function push(name, cfg, args)
        local scene = objectfactory:createClassInstance(cfg.pushName or "MainScene")

        object:setSceneObject(scene)
        object:setSceneName(name)

        if DEBUG_LOG_UICTX then
            object:logDEBUG("INIT场景: [%s]", name)
        end

        if onInitPush then
            onInitPush()
        end

        scene:ctor(unpack(args))
        cc.Director:getInstance():pushScene(scene)

        isPushed = true

        if DEBUG_LOG_UICTX then
            object:logDEBUG("PUSH场景: [%s]", name)
        end

        if onPush then
            onPush()
        end
    end

    local function back()
        if DEBUG_LOG_UICTX then
            object:logDEBUG("BACK场景: [%s]", object:getSceneName())
        end

        if onBack then
            onBack()
        end

        isPushed = false

        object:setSceneObject(object:getRootSceneObject())
        object:setSceneName(object:getRootSceneName())

        cc.Director:getInstance():popToRootScene()
    end

----------------------------------------
-- 对象方法·场景 (replace)
----------------------------------------

    local ModuleConfig = args.ModuleConfig or {}

    function object:goto(name, ...)
        local cfg = ModuleConfig[name]

        if not cfg      then
            return self:logERROR("GOTO场景: [%s]没有找到", name)
        end

        if not cfg.goto then
            return self:logERROR("GOTO场景: [%s]不支持", name)
        end

        if isPushed then
            objectfactory:backSearchPaths()
            back()
        end

        if object:getRootSceneName() then

            if DEBUG_LOG_UICTX then
                object:logDEBUG("EXIT场景: [%s]", object:getRootSceneName())
            end

            if onExit then
                onExit()
            end

            object:setPrevSceneName(object:getRootSceneName())
        end

        objectfactory:setSearchPaths(cfg.searchPaths)
        goto(name, cfg, { ... })
    end

----------------------------------------
-- 对象方法·场景 (push&pop)
----------------------------------------

    function object:push(name, ...)
        local cfg = ModuleConfig[name]

        if not cfg      then
            return self:logERROR("PUSH场景: [%s]没有找到", name)
        end

        if not cfg.push then
            return self:logERROR("PUSH场景: [%s]不支持", name)
        end

        if isPushed then
            return self:logERROR("PUSH场景: [%s]无法执行", name)
        end

        objectfactory:pushSearchPaths(cfg.searchPaths)
        push(name, cfg, { ... })
    end

    function object:gotoBack()
        if isPushed then
            objectfactory:backSearchPaths()
            back()
        end
    end

    return component
end

