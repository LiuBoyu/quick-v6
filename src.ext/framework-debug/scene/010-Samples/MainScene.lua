
local res = "framework-debug/scene/010-Samples/"

local Img = {
    Card1       = res .. "card1.png",
    Option      = res .. "option.png",
}

local M = class("UnitTest", function()
    return display.newScene()
end)

function M:ctor(args)
    UI:DebugScene(self, args)
        :addComponent(".MainUICtrl")

    local clear = function()
        if self.node then
            self.node:removeSelf()
        end
        self.node = display.newNode()
            :addTo(self)
    end

    G.Ctx:getObjectFactory():setPushedSearchPaths({ PROJNS .. ".scene.Common" })

    ----------------
    -- UI
    ----------------

    self:MENU("UI")

    -- 精灵

    self:TEST("精灵(背景)", function()
        clear()

        local a = display.newSprite(Img.Card1)
            :align(display.CENTER, display.cx, display.cy)
            :addTo(self.node)
    end)

    -- 文本

    self:TEST("文本(TTF.EN)", function()
        clear()

        local a = display.newText({ text = "HelloWorld", size = 32, font = Font.DEFAULT })
            :align(display.CENTER, display.cx, display.cy)
            :addTo(self.node)
    end)

    self:TEST("文本(TTF.CN)", function()
        clear()

        local a = display.newText({ text = "< english 简体中文 हिन्दी বাংলা मराठी ગુજરાતી >", size = 32, font = Font.DEFAULT })
            :align(display.CENTER, display.cx, display.cy)
            :addTo(self.node)
    end)

    -- 数字

    self:TEST("数字(静态)", function()
        clear()

        local a = display.newNumber({ text = 0, size = 32, font = Font.DEFAULT })
            :align(display.CENTER, display.cx, display.cy - 50)
            :addTo(self.node)
    end)

    self:TEST("数字(动态)", function()
        clear()

        local a = display.newNumber({ text = 0, size = 32, font = Font.DEFAULT })
            :align(display.CENTER, display.cx, display.cy - 50)
            :addTo(self.node)

        a:setNumber(100, { duration = 1.0 })
    end)

    -- 按钮

    self:TEST("按钮(图片)", function()
        clear()

        local a = display.newSprite(Img.Card1)
            :align(display.CENTER, display.cx, display.cy)
            :addTo(self.node)
        UI:Button(a)

        a:setOnTap(function()
            print("点击")
        end)
    end)

    self:TEST("按钮(文字)", function()
        clear()

        local a = display.newText({ text = "HelloWorld", size = 32, font = Font.DEFAULT })
            :align(display.CENTER, display.cx, display.cy)
            :addTo(self.node)
        UI:Button(a)

        a:setOnTap(function()
            print("点击")
        end)
    end)

    self:TEST("拖拽(图片)", function()
        clear()

        local a = display.newSprite(Img.Card1)
            :align(display.CENTER, display.cx, display.cy)
            :addTo(self.node)
        UI:DragDrop(a)

        -- a:setOnDrag(function(e)
        --     print("拖拽")
        -- end)
        a:setOnDrop(function(e)
            print("落下")
        end)
    end)

    -- 九宫图

    self:TEST("九宫图", function()
        clear()

        local a = display.newScale9Sprite(Img.Card1, 0, 0, cc.size(600, 47))
            :align(display.CENTER, display.cx, display.cy+100)
            :addTo(self.node)

        local b = display.newScale9Sprite(Img.Card1, 0, 0, cc.size(200, 47))
            :align(display.CENTER, display.cx, display.cy+50)
            :addTo(self.node)

        local c = display.newScale9Sprite(Img.Card1, 0, 0, cc.size(200, 100))
            :align(display.CENTER, display.cx, display.cy-30)
            :addTo(self.node)
    end)

    -- 进度

    self:TEST("进度条", function()
        clear()

        local a = display.newProgressTimer(Img.Card1, display.PROGRESS_TIMER_BAR)
            :align(display.CENTER, display.cx, display.cy)
            :addTo(self.node)
        a:setBarChangeRate(cc.p(1, 0))
        a:setMidpoint(cc.p(0.0, 0.5))
        a:setPercentage(0)

        a:playAction(cc.ProgressTo:create(1, 100), {
            onComplete = function()
                print("done!")
            end,
        })
    end)

    self:TEST("进度框", function()
        clear()

        local a = display.newProgressTimer(Img.Card1, display.PROGRESS_TIMER_RADIAL)
            :align(display.CENTER, display.cx, display.cy)
            :addTo(self.node)
        a:setMidpoint(cc.p(0.5, 0.5))
        a:setPercentage(0)

        a:playAction(cc.ProgressTo:create(1, 100), {
            onComplete = function()
                print("done!")
            end,
        })
    end)

    -- 动作

    self:TEST("动作(基础)", function()
        clear()

        local a = display.newSprite(Img.Card1)
            :align(display.CENTER, display.cx, display.cy)
            :addTo(self.node)

        a:performWithDelay(function()
            a:moveTo(1.0, 0, 0)
        end, 1.0)

        a:performWithDelay(function()
            a:moveTo(1.0, display.cx, display.cy)
        end, 2.0)

        a:performWithDelay(function()
            a:scaleTo(1.0, 0.5)
        end, 3.0)

        a:performWithDelay(function()
            a:scaleTo(1.0, 1.0)
        end, 4.0)
    end)

    self:TEST("动作(复杂)", function()
        clear()

        local a = display.newSprite(Img.Card1)
            :align(display.CENTER, display.cx, display.cy)
            :addTo(self.node)

        a:playAction(cc.Sequence:create({
            cc.MoveTo:create(1.0, cc.p(0, 0)),
            cc.MoveTo:create(1.0, cc.p(display.cx, display.cy)),
            cc.ScaleTo:create(1.0, 0.5),
            cc.ScaleTo:create(1.0, 1.0),
        }), {
            easing     = { "BACKIN" },
            delay      = 1.0,
            onComplete = function()
                print("done!!!")
            end,
        })
    end)

    self:TEST("动作(果冻1)", function()
        clear()

        local b = display.newNode()
            :align(display.CENTER, display.cx, display.cy)
            :addTo(self.node)

        local a = display.newSprite(Img.Card1)
            :align(display.CENTER, 0, 0)
            :addTo(b)

        b:playAction(cc.Spawn:create({
            cc.TargetedAction:create(a, cc.EaseBounceOut:create(
                cc.Sequence:create({
                    cc.ScaleTo:create(0.1, 0.8, 1.0),
                    cc.ScaleTo:create(0.2, 1.0, 1.0),
                })
            )),
            cc.TargetedAction:create(b, cc.EaseBounceOut:create(
                cc.Sequence:create({
                    cc.ScaleTo:create(0.1, 1.0, 1.2),
                    cc.ScaleTo:create(0.2, 1.0, 1.0),
                })
            )),
        }), {
            onComplete = function()
                print("done!!!")
            end,
        })
    end)

    self:TEST("动作(果冻2)", function()
        clear()

        local b = display.newNode()
            :align(display.CENTER, display.cx, display.cy)
            :addTo(self.node)

        local a = display.newSprite(Img.Card1)
            :align(display.CENTER, 0, 0)
            :addTo(b)

        b:playAction(cc.Spawn:create({
            cc.TargetedAction:create(a, cc.EaseElasticOut:create(
                cc.Sequence:create({
                    cc.ScaleTo:create(0.1, 0.6, 1.0),
                    cc.ScaleTo:create(0.2, 1.0, 1.0),
                })
            )),
            cc.TargetedAction:create(b, cc.EaseElasticOut:create(
                cc.Sequence:create({
                    cc.ScaleTo:create(0.1, 1.0, 1.4),
                    cc.ScaleTo:create(0.2, 1.0, 1.0),
                })
            )),
        }), {
            onComplete = function()
                print("done!!!")
            end,
        })
    end)

    ----------------
    -- UI
    ----------------

    self:MENU("UI", { newline = false })

    -- 计时器

    self:TEST("*计时器(节点)", function()
        clear()
    end)

    self:TEST("*计时器(全局)", function()
        clear()
    end)

    self:TEST("文本(多语言)", function()
        clear()

        local t = display.newTextByI18N({ id = "LANGUAGE", size = 32 })
            :align(display.CENTER, display.cx-100, display.cy)
            :addTo(self.node)

        local l = { "EN_US", "ZH_CN", "HI_IN", "BN_IN", "MR_IN", "GU_IN" }

        for i = 1, 6 do
            local language = l[i]

            local o = display.newText({ text = language, size = 32, font = Font.DEFAULT })
                :align(display.CENTER, display.cx+200, display.cy + 160 - 40 * i)
                :addTo(self.node)
            UI:Button(o)

            o:setOnTap(function()
                t:setI18N(language)
            end)
        end
    end)

    self:TEST("文本(I18N)", function()
        clear()

        local t = display.newTextByI18N({ id = "LANGUAGE", size = 32 })
            :align(display.CENTER, display.cx-100, display.cy)
            :addTo(self.node)

        UI:I18N(t)
        t:setOnI18N(function(language)
            print(language)
        end)

        local l = { "EN_US", "ZH_CN", "HI_IN", "BN_IN", "MR_IN", "GU_IN" }

        for i = 1, 6 do
            local o = display.newText({ text = l[i], size = 32, font = Font.DEFAULT })
                :align(display.CENTER, display.cx+200, display.cy + 160 - 40 * i)
                :addTo(self.node)
            UI:Button(o)

            o:setOnTap(function()
                G.Ctx:dispatchEvent("I18N", { language = l[i] })
            end)
        end
    end)

    ----------------
    -- UI
    ----------------

    self:MENU("UI", { newline = false })

    self:TEST("Busy(UI)", function()
        clear()

        local a = display.newSprite(Img.Card1)
            :align(display.CENTER, display.cx, display.cy)
            :addTo(self.node)

        UI:Button(a)
            :addComponent("UI.Busy")

        a:performWithBusy(function(done)
            self:performWithDelay(function()
                done()
            end, 3.0)
        end)
    end)

    self:TEST("Busy(Dialog)", function()

        G.Ctx:performWithBusy(function(done)
            self:performWithDelay(function()
                done()
            end, 3.0)
        end)

    end)

    ----------------
    -- Dialog
    ----------------

    self:MENU("Dialog", { newline = false })

    self:TEST("对话框(简单)", function()

        G.Ctx:showDialog("Sample01Dialog", { mode = 1 })

    end)

    self:TEST("对话框(遮盖)", function()

        G.Ctx:showDialog("Sample01Dialog", { mode = 2 })

    end)

    ----------------
    -- Net
    ----------------

    self:MENU("Other", { newline = false })

    self:TEST("震动", function()

        G.App:vibrate(500)

    end)

    self:TEST("时间(毫秒)", function()

        print(os.time())
        print(gettime())

    end)

    ----------------
    -- Component
    ----------------

    self:MENU("Component", { newline = false })

    self:TEST("UrlPic", function()
        clear()

        local a = display.newSprite()
            :align(display.CENTER, display.cx, display.cy)
            :addTo(self.node)

        Component(a)
            :addComponent("UI.UrlPic")

        a:setUrl("http://192.168.0.19:8080/redeem/001.png")
    end)

    self:TEST("GRAY", function()
        clear()

        local a = display.newFilteredSprite(Img.Card1)
            :align(display.CENTER, display.cx, display.cy)
            :addTo(self.node)

        local b = 1

        UI:Button(a)
        a:setOnTap(function()
            b = (b + 1) % 2

            if b == 0 then
                a:setFilter(filter.newFilter("GRAY"))
            else
                a:clearFilter()
            end
        end)
    end)

    self:TEST("OUTLINE", function()
        clear()

        local a = display.newFilteredSprite(Img.Card1)
            :align(display.CENTER, display.cx, display.cy)
            :addTo(self.node)

        local param = json.encode({
            frag = "framework-debug/shader/outline.fsh",
            shaderName = "OUTLINE",
            u_outlineColor = {255/255, 0/255, 0/255},
            u_radius = 0.002,
            u_threshold = 1.75,
        })

        local b = 1

        UI:Button(a)
        a:setOnTap(function()
            b = (b + 1) % 2

            if b == 0 then
                a:setFilter(filter.newFilter("CUSTOM", param))
            else
                a:clearFilter()
            end
        end)
    end)

    self:TEST("FIREBALL", function()
        clear()

        local a = display.newFilteredSprite(Img.Card1)
            :align(display.CENTER, display.cx, display.cy)
            :addTo(self.node)

        local param = json.encode({
            frag = "framework-debug/shader/fireball.fsh",
            shaderName = "FIREBALL",
            center = { display.widthInPixels/2, display.heightInPixels/2 },
            resolution = { 200, 200 },
        })

        local b = 1

        UI:Button(a)
        a:setOnTap(function()
            b = (b + 1) % 2

            if b == 0 then
                a:setFilter(filter.newFilter("CUSTOM", param))
            else
                a:clearFilter()
            end
        end)
    end)

    self:TEST("HUE", function()
        clear()
        local a = display.newFilteredSprite(Img.Card1, "HUE")
            :align(display.CENTER, display.cx, display.cy)
            :addTo(self.node)

        local b = display.newText({})
            :align(display.CENTER, 0, 0)
            :addTo(a)

        local p = 0

        a:schedule(function()
            p = (p + 10)%360

            b:setText(p)

            a:getFilter():setParameter(p)
            a:setFilter(a:getFilter())
        end, 0.1)

        UI:Button(a)
        a:setOnTap(function()
        end)
    end)

    self:TEST("RGB", function()
        clear()
        local a = display.newFilteredSprite(Img.Card1, "RGB")
            :align(display.CENTER, display.cx, display.cy)
            :addTo(self.node)

        local b = display.newText({})
            :align(display.CENTER, 0, 0)
            :addTo(a)

        local r = 0
        local p = 0

        a:schedule(function()
            r = (r + 10)%255
            p = r/255

            b:setText(r)

            a:getFilter():setParameter(p, 0, 0)
            a:setFilter(a:getFilter())
        end, 0.1)

        UI:Button(a)
        a:setOnTap(function()
        end)
    end)

    self:TEST("系统字体", function()
        clear()

        local x = display.cx
        local y = display.cy + 100

        local output = function(font)
            display.newText({ text = "HelloWorld 1234567890", size = 32, font = font })
                :align(display.CENTER, x - 200, y)
                :addTo(self.node)
            display.newText({ text = font, size = 32, font = font })
                :align(display.CENTER, x + 200, y)
                :addTo(self.node)
            y = y - 30
        end

        if PLATFORM_IOS     then
            -- todo
        end

        if PLATFORM_ANDROID then
            output("normal")
            output("normal@Bold")
            output("sans")
            output("sans@Bold")
            output("serif")
            output("serif@Bold")
            output("monospace")
            output("monospace@Bold")
        end

        if PLATFORM_UNKNOWN then
            output("Arial")
            output("Arial@Bold")
            output("Courier")
            output("Courier@Bold")
        end
    end)

    self:TEST("系统消息", function()
        clear()

        G.Ctx:showSysMsg({ text = "HelloWorld" })
        G.Ctx:showSysMsg({ errorCode = 1000, errorMessage = "Error1000" })
    end)

    self:TEST("数字格式", function()
        clear()

        print( string.formatnumbershorts(1) )
        print( string.formatnumbershorts(12) )
        print( string.formatnumbershorts(123) )
        print( string.formatnumbershorts(1234) )
        print( string.formatnumbershorts(12345) )
        print( string.formatnumbershorts(123456) )
        print( string.formatnumbershorts(1234567) )
        print( string.formatnumbershorts(12345678) )
        print( string.formatnumbershorts(123456789) )
        print( string.formatnumbershorts(1234567890) )

        local x = display.cx - 100
        local y = display.cy + 100

        local output = function(v)
            display.newNumber({ text = v, size = 32, font = Font.DEFAULT, thousands = true, shorts = true })
                :align(display.LEFT_CENTER, x, y)
                :addTo(self.node)
            y = y - 30
        end

        output(1)
        output(12)
        output(123)
        output(1234)
        output(12345)
        output(123456)
        output(1234567)
        output(12345678)
        output(123456789)
        output(1234567890)
    end)

    self:TEST("数字格式化", function()
        clear()

        print( string.format("%02d:%02d", 1, 13) )

    end)

    ----------------
    -- Debug
    ----------------

    self:MENU("Debug", { newline = false })

    -- 基准线

    local baseline

    self:TEST("基准线", function()
        if baseline then
            baseline:removeSelf()
            baseline = nil
        else
            baseline = display.newNode()
                :addTo(G.Ctx:getSceneObject():getComponent("UI.Scene"):getEditor(), 200)

            local W = DESIGN_SCREEN_WIDTH
            local H = DESIGN_SCREEN_HEIGHT

            local min =  4/3
            local max = 16/9

            local w = (H * min)/2
            local h = (W / max)/2

            local a = display.newLine({ {display.cx - w, 0}, {display.cx - w, H} }, { borderColor = cc.c4f(1.0, 0.0, 0.0, 0.8), borderWidth = 2 })
                :addTo(baseline)
            local b = display.newLine({ {display.cx + w, 0}, {display.cx + w, H} }, { borderColor = cc.c4f(1.0, 0.0, 0.0, 0.8), borderWidth = 2 })
                :addTo(baseline)
            local c = display.newLine({ {0, display.cy - h}, {W, display.cy - h} }, { borderColor = cc.c4f(1.0, 0.0, 0.0, 0.8), borderWidth = 2 })
                :addTo(baseline)
            local d = display.newLine({ {0, display.cy + h}, {W, display.cy + h} }, { borderColor = cc.c4f(1.0, 0.0, 0.0, 0.8), borderWidth = 2 })
                :addTo(baseline)
        end
    end)

    -- 网格线

    local gridline

    self:TEST("网格线", function()
        if gridline then
            gridline:removeSelf()
            gridline = nil
        else
            gridline = display.newNode()
                :addTo(G.Ctx:getSceneObject():getComponent("UI.Scene"):getEditor(), 100)

            local c = cc.DrawNode:create()
                :addTo(gridline)

            local w, h = display.width, display.height
            local x, y = display.cx,    display.cy

            c:drawDot(cc.p(x,y), 5, cc.c4f(1,0,0,0.8))

            x = display.cx
            while x < display.right  do
                c:drawSegment(cc.p(x, 0), cc.p(x, h), 1, cc.c4f(1,0,0,0.2))
                x = x + 50
            end
            x = display.cx
            while x > display.left   do
                c:drawSegment(cc.p(x, 0), cc.p(x, h), 1, cc.c4f(1,0,0,0.2))
                x = x - 50
            end
            y = display.cy
            while y < display.top    do
                c:drawSegment(cc.p(0, y), cc.p(w, y), 1, cc.c4f(1,0,0,0.2))
                y = y + 50
            end
            y = display.cy
            while y > display.bottom do
                c:drawSegment(cc.p(0, y), cc.p(w, y), 1, cc.c4f(1,0,0,0.2))
                y = y - 50
            end
        end
    end)

    -- 调试

    self:TEST("UI调试", function()
        clear()

        local a = display.newSprite(Img.Card1)
            :align(display.CENTER, display.cx, display.cy)
            :addTo(self.node)
        UI:DEBUG(a)

        local b = display.newSprite(Img.Option)
            :align(display.CENTER, display.cx+100, display.cy+130)
            :addTo(self.node)
        UI:Button(b)
        UI:DEBUG(b)
    end)

end

return M

