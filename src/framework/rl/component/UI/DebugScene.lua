
----------------------------------------
-- 组件·UI·测试场景 DebugScene
----------------------------------------

return function(object, args)

    local component = { id = "UI.DebugScene" }

----------------------------------------
-- 组件依赖
----------------------------------------

    if not object:isComponent("UI.Scene") then object:addComponent("UI.Scene") end

----------------------------------------
-- 组件参数
----------------------------------------

    local args = args or {}

----------------------------------------
-- 对象方法·TEST
----------------------------------------

    local col = 0
    local row = 0

    local debug = display.newNode()
        :addTo(object, 9999)
        :hide()

    local function createMenuNode(text)
        local node = display.newTTFLabel({ text = text, size = 64, font = "Courier", color = cc.c3b(255,255,0), textAlign = cc.TEXT_ALIGNMENT_CENTER })
        local rect = node:getBoundingBox()
        if rect.width > 320 then
            node:setScale(320/rect.width)
        end
        node:setScale(node:getScale() / 2)
        return node
    end

    local function createTestNode(text, callback)
        local node = display.newTTFLabel({ text = text, size = 64, font = "Courier", color = cc.c3b(127,255,0), textAlign = cc.TEXT_ALIGNMENT_CENTER })
        UI:Button(node, { mode = "fast" })

        local rect = node:getBoundingBox()
        if rect.width > 320 then
            node:setScale(320/rect.width)
        end
        node:setScale(node:getScale() / 2)

        node:setOnRelease(function()
            node:setScale(node:getScale() / 1.5)
        end)
        node:setOnPress(function()
            node:setScale(node:getScale() * 1.5)
        end)

        node:setOnTap(callback)
        return node
    end

    function object:MENU(name, opts)
        local opts = opts or {}

        if opts.newline == nil then
            opts.newline = true
        end

        if opts.newline then
            col = col + 1
            row = 0
        else
            row = row + 1
        end

        if not name then
            return
        end

        row = row + 1

        local x = display.left + 80 + 180 * (col - 1)
        local y = display.top  - 40 -  36 * (row - 1)

        if y < 0 then
            self:MENU(name)
            return
        end

        local node = createMenuNode(name)
            :align(display.CENTER, x, y)
            :addTo(debug)
    end

    function object:TEST(name, callback)
        if not name then
            return
        end

        row = row + 1

        local x = display.left + 80 + 180 * (col - 1)
        local y = display.top  - 40 -  36 * (row - 1)

        if y < 0 then
            col = col + 1
            row = 1

            self:TEST(name, callback)
            return
        end

        local callback = function()
            local node = self["~sandbox~"]

            if node then
                node:removeSelf()
            end

            node = display.newNode()
                :addTo(self, 4000)

            self["~sandbox~"] = node

            if callback then
                return callback(node)
            end
        end

        local node = createTestNode(name, callback)
            :align(display.CENTER, x, y)
            :addTo(debug)
    end

----------------------------------------
-- 对象方法·CONSOLE
----------------------------------------

    local console = display.newNode()
        :addTo(object, 9998)
        :hide()

    local bg = display.newColorLayer(cc.c4b(0,0,0,127))
        :addTo(console)
    bg:setContentSize(display.width, display.height/2)

    local lb = display.newTTFLabel({
            text = "",
            font = "Courier",
            size = 12,
            valign     = cc.VERTICAL_TEXT_ALIGNMENT_BOTTOM,
            dimensions = cc.size(display.width - 20, display.height/2),
            color      = cc.c3b(255, 255, 255),
        })
        :align(display.LEFT_BOTTOM, 10, 0)
        :addTo(console)

    function object:CONSOLE(tag, fmt, ...)
        local fmt = fmt or ""
        local args = { ... }

        if tag == "@toggle" then
            if console:isVisible() then
                return console:hide()
            else
                return console:show()
            end
        end

        if tag == "@show" then
            return console:show()
        end
        if tag == "@hide" then
            return console:hide()
        end

        for i = 1, 8 do
            args[i] = tostring(args[i])
        end

        local str = table.concat({ lb:getString(), "\n", "[", tag, "]", " ", string.format(fmt, unpack(args)) })
        lb:setString(str)

        local n = lb:getStringNumLines() - 18

        for i = 1, n do
            str = string.sub(str, string.find(str, "\n") + 1)
        end

        if n > 0 then
            lb:setString(str)
        end
    end

----------------------------------------
-- 对象方法·SHOW/HIDE
----------------------------------------

    local status = 0

    local function createShowNode()
        local node = display.newTTFLabel({ text = "SHOW", size = 32, font = "Courier", color = cc.c3b(255,0,0), textAlign = cc.TEXT_ALIGNMENT_CENTER })
        UI:Button(node, { mode = "fast" })

        node:setOnTap(function()
            status = status + 1

            if status > 1 then
                status = status - 2
            end

            object:SHOW(status)
        end)
        return node
    end

    local show = createShowNode()
        :align(display.LEFT_CENTER, display.left + 5, display.top - 12)
        :addTo(object, 9999)

    function object:SHOW(name)
        if     name == 0 or name == "NONE"  then
            status = 0
            show:setString("SHOW")
            debug:hide()
        elseif name == 1 or name == "DEBUG" then
            status = 1
            show:setString("DEBUG")
            debug:show()
        end
    end

----------------------------------------
-- 对象方法·BACK
----------------------------------------

    local function createBackNode()
        local node = display.newTTFLabel({ text = "Back", size = 32, font = "Courier", color = cc.c3b(255,0,0), textAlign = cc.TEXT_ALIGNMENT_CENTER })
        UI:Button(node)

        node:setOnTapOnce(function()
            if rl.G.UIDebugSceneOnGotoBack then
                rl.G.UIDebugSceneOnGotoBack()
            end
        end)
        return node
    end

    local back = createBackNode()
        :align(display.RIGHT_CENTER, display.right - 5, display.top - 12)
        :addTo(object, 9999)

    return component
end

