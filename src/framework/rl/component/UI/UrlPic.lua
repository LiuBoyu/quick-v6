
----------------------------------------
-- 组件·UI·远程图片 UrlPic
----------------------------------------

return function(object, args)

    local component = { id = "UI.UrlPic" }

----------------------------------------
-- 组件依赖
----------------------------------------

    if not object:isComponent("HttpProxy") then object:addComponent("HttpProxy", { client = rl.G.UIUrlPicClient, filter = rl.G.UIUrlPicFilter }) end

----------------------------------------
-- 组件参数
----------------------------------------

    local args = args or {}

    local url = args.url

    local cache = rl.Cache.new({
        storagePath = rl.G.UIUrlPicCache.storagePath,
        storageType = "file",
        contentType = "?",
        expires     = rl.G.UIUrlPicCache.expires,
    })

----------------------------------------
-- 对象方法·远程图片
----------------------------------------

    function object:setUrl(url)
        return self:DOWNLOAD("", {
            url = url,
            onComplete = function(e)
                if e.status ~= 200 then return end

                if e.filename then

                    local spriteframe = display.newSprite(e.filename):getSpriteFrame()
                    object:setSpriteFrame(spriteframe)

                end
            end,
            cache = cache,
        })
    end

----------------------------------------
-- 对象方法·远程图片
----------------------------------------

    if url then
        object:setUrl(url)
    end

    return component
end

