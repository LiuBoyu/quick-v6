
----------------------------------------
-- shortcodes
----------------------------------------

function cc.Node:placeTo(x, y)
    return self:pos(x, y)
end

function cc.Node:placeBy(x, y)
    local sx, sy = self:getPosition()
    self:setPosition(sx + x, sy + y)
    return self
end

function cc.Node:ignoreAP(ignore)
    self:ignoreAnchorPointForPosition(ignore)
    return self
end

function cc.Node:visible(enabled)
    self:setVisible(enabled)
    return self
end

function cc.Node:color(r, g, b)
    self:setColor(cc.c3b(r, g, b))
    return self
end

function cc.Node:opacityModifyRGB(enabled)
    self:setOpacityModifyRGB(enabled)
    return self
end

function cc.Node:cascadeColor(enabled)
    self:setCascadeColorEnabled(enabled)
    return self
end

function cc.Node:cascadeOpacity(enabled)
    self:setCascadeOpacityEnabled(enabled)
    return self
end

--[[
#define GL_ZERO                 0
#define GL_ONE                  1
#define GL_SRC_COLOR            0x0300
#define GL_ONE_MINUS_SRC_COLOR  0x0301
#define GL_SRC_ALPHA            0x0302
#define GL_ONE_MINUS_SRC_ALPHA  0x0303
#define GL_DST_ALPHA            0x0304
#define GL_ONE_MINUS_DST_ALPHA  0x0305
#define GL_DST_COLOR            0x0306
#define GL_ONE_MINUS_DST_COLOR  0x0307
--]]

display.BLEND_SPOTLIGHT     = {}
display.BLEND_SPOTLIGHT.src = gl.SRC_COLOR
display.BLEND_SPOTLIGHT.dst = gl.DST_ALPHA

function cc.Node:blend(ccBlendFunc)
    self:setBlendFunc(ccBlendFunc.src, ccBlendFunc.dst)
    return self
end

function cc.Node:lineColor(r, g, b, o)
    self:setLineColor(cc.c4fFromc4b(cc.c4b(r, g, b, o)))
    return self
end

