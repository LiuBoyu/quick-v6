
local display = display or {}

----------------------------------------
-- capture
----------------------------------------

-- 截屏(节点)并保存为一个文件

local saveToFile = function(canvas, args)
    -- 保存截屏
    local filename = args.filename

    if filename then
        if string.startswith(filename, device.writablePath) then
            filename = string.sub(filename, string.len(device.writablePath) + 1)
        end
        canvas:saveToFile(filename, cc.IMAGE_FORMAT_JPEG, false)
    end

    -- 调用回调(下一帧)
    local callback = args.callback

    if callback then
        scheduler.performWithDelayGlobal(function()
            callback()
        end, 0)
    end
end

-- function display.captureScreen(args)
--     local canvas = cc.RenderTexture:create(display.width, display.height, cc.TEXTURE2D_PIXEL_FORMAT_RGBA8888, gl.DEPTH24_STENCIL8_OES)

--     canvas:begin()
--     rl.G.Ctx:getSceneObject():visit()
--     canvas:endToLua()

--     saveToFile(canvas, args)
-- end

function display.captureScreen(args)
    local filename = args.filename
    local callback = args.callback or function() end
    cc.utils:captureScreen(callback, filename)
end

function display.capture(node, args)
    local args = args or {}

    -- 设置节点
    local rect = node:getCascadeBoundingBox()

    local size = args.size

    if size then
        node:setScaleX(node:getScaleX() * size.width  / rect.width )
        node:setScaleY(node:getScaleY() * size.height / rect.height)
    end

    if size then
        rect = node:getCascadeBoundingBox()
    end

    node:setPositionX(-rect.x)
    node:setPositionY(-rect.y)

    -- 绘制节点
    local canvas = cc.RenderTexture:create(rect.width, rect.height, cc.TEXTURE2D_PIXEL_FORMAT_RGBA8888, gl.DEPTH24_STENCIL8_OES)

    canvas:begin()
    node:visit()
    canvas:endToLua()

    -- 保存节点
    saveToFile(canvas, args)
end

----------------------------------------
-- label
----------------------------------------

local BMFontHeight = {
      4,  4,  8,  8, 10, 10, 10, 14, 14, 16, 16, 20, 20, 22, 22, 20,
     22, 22, 24, 24, 26, 28, 28, 30, 30, 32, 32, 34, 34, 36, 38, 38,
     40, 40, 42, 44, 44, 44, 46, 46, 48, 50, 50, 52, 54, 54, 56, 56,
     56, 58, 60, 60, 62, 62, 64, 66, 66, 68, 68, 70, 70, 72, 72, 74,
     76, 76, 78, 78, 80, 80, 82, 82, 84, 86, 86, 88, 88, 90, 92, 92,
     92, 94, 96, 96, 98, 98,100,102,102,102,104,104,106,108,108,110,
    112,112,114,114,114,116,118,118,120,120,122,124,124,126,126,128,
    128,130,130,132,134,134,136,136,138,138,140,140,142,144,144,146,
    146,148,150,150,150,152,154,154,156,156,158,160,160,162,162,164,
    164,166,166,168,170,170,172,172,174,174,176,176,178,178,180,182,
    182,184,186,186,186,188,188,190,192,192,194,194,196,198,198,198,
    200,202,202,204,204,206,208,208,208,210,212,212,214,214,216,218,
    218,220,220,222,222,224,224,226,228,228,230,230,232,232,234,234,
    236,238,238,240,240,242,244,244,244,246,246,248,250,250,252,252,
    254,256,256,256,258,260,260,262,262,264,266,266,268,268,270,270,
    272,272,274,276,276,278,278,280,280,282,282,284,286,286,288,288,
}

function display.newText(args)
    local font  = args.font or display.DEFAULT_TTF_FONT
    local size  = args.size or display.DEFAULT_TTF_FONT_SIZE

    local outline, shadow

    if type(font) == "string" then
        if rl.G.Font[font] then
            font = rl.G.Font[font]
        end
    end

    if type(font) == "table" then
        outline = font.outline
        shadow  = font.shadow
        font    = font.font or display.DEFAULT_TTF_FONT
    end

    outline = args.outline or outline
    shadow  = args.shadow  or shadow

    local label

    if string.sub(font, -3) == "fnt" then
        label = cc.ui.UILabel.new({
                UILabelType = cc.ui.UILabel.LABEL_TYPE_BM,
                text        = args.text,
                font        = font,
                align       = args.align,
                x           = args.x,
                y           = args.y,
            })
        label._scale_ = BMFontHeight[size] / label:getContentSize().height
    else
        label = cc.ui.UILabel.new({
                UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
                text        = args.text,
                font        = font,
                size        = size,
                color       = args.color,
                align       = args.align,
                valign      = args.valign,
                x           = args.x,
                y           = args.y,
                dimensions  = args.dimensions,
            })
        label._scale_ = 1.0
    end

    label._width_ = args.width or 0

    if outline then
        if type(outline) ~= "table" then
            label:enableOutline(outline.color or cc.c4b(0,0,0,255), outline.size or 1)
        else
            label:enableOutline(cc.c4b(0,0,0,255), 1)
        end
    end

    if shadow then
        if type(shadow) == "table" then
            label:enableShadow(shadow.color or cc.c4b(0,0,0,255), shadow.offset or cc.size(2,-2), shadow.blurRadius or 0)
        else
            label:enableShadow(cc.c4b(0,0,0,255), cc.size(2,-2), 0)
        end
    end

    function label:_apply_()
        label:scale(label._scale_)

        local width = label:getBoundingBox().width

        if 0 < label._width_ and label._width_ < width then
            label:scale(label._scale_ * label._width_ / width)
        end
    end

    function label:setText(txt)
        self:setString(txt)
        self:_apply_()
    end

    function label:getText()
        return self:getString()
    end

    label:_apply_()
    return label
end

function display.newTextByI18N(args)
    local label = display.newText(args)

    local language = args.language or LANGUAGE
    local id       = args.id

    function label:setI18N(i18n)
        self:setText(rl.G.Text(id, i18n))
        language = i18n
    end

    function label:getI18N()
        return language
    end

    function label:resetI18N()
        self:setI18N(LANGUAGE or "EN_US")
    end

    label:setI18N(language)
    return label
end

function display.newNumber(args)
    local label = display.newText(args)

    label._thousands_ = args.thousands or false
    label._shorts_    = args.shorts    or false
    label._duration_  = args.duration  or 0
    label._new_value_ = 0
    label._old_value_ = 0
    label._add_value_ = 0

    function label:setNumber(val, args)
        local args = args or {}

        local val      = tonumber(val)
        local duration = args.duration or label._duration_

        label._new_value_ = val

        if duration > 0 then
            label._add_value_ = math.ceil((label._new_value_ - label._old_value_)/24/duration)

            local function addVal()
                label:performWithDelay(function()
                    label._old_value_ = label._old_value_ + label._add_value_

                    if (label._old_value_ >= label._new_value_ and label._add_value_ >= 0)
                    or (label._old_value_ <= label._new_value_ and label._add_value_ <= 0) then
                        label._old_value_ = label._new_value_
                        label._add_value_ = 0
                    else
                        addVal()
                    end

                    if     label._shorts_    then
                        label:setText(string.formatnumbershorts   (label._old_value_))
                    elseif label._thousands_ then
                        label:setText(string.formatnumberthousands(label._old_value_))
                    else
                        label:setText(label._old_value_)
                    end
                end, 1/24)
            end

            addVal()
        else
            label._old_value_ = label._new_value_
            label._add_value_ = 0

            if     label._shorts_    then
                label:setText(string.formatnumbershorts   (label._old_value_))
            elseif label._thousands_ then
                label:setText(string.formatnumberthousands(label._old_value_))
            else
                label:setText(label._old_value_)
            end
        end
    end

    function label:getNumber()
        return label._new_value_
    end

    label:setNumber(args.text, { duration = 0 })
    return label
end

function display.newSpriteByI18N(filename, language)
    local prefix = string.sub(filename, 1, #filename - 4)
    local suffix = string.sub(filename, -4)

    filename = prefix .. "_" .. string.upper(language or LANGUAGE or "EN_US") .. suffix

    if os.exists(filename) then
        return display.newSprite(filename)
    else
        return display.newSprite()
    end
end

