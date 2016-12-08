
local UI = {}

setmetatable(UI, { __call = function(self, object, args) return self:Component(object, args) end })

function UI:Component(object, args)
    if not object.isComponent then
        rl.Component(object, args)
    end
    return object
end

function UI:Button(object, args)
    return UI:Component(object, args):addComponent("UI.Button", args)
end

function UI:Dialog(object, args)
    return UI:Component(object, args):addComponent("UI.Dialog", args)
end

function UI:UrlPic(object, args)
    return UI:Component(object, args):addComponent("UI.UrlPic", args)
end

function UI:I18N(object, args)
    return UI:Component(object, args):addComponent("UI.I18N", args)
end

function UI:DEBUG(object, args)
    if DEBUG_LOG_UI then
        return UI:Component(object, args):addComponent("UI.Debug", args)
    end
    return object
end

function UI:Scene(object, args)
    return UI:Component(object, args):addComponent("UI.Scene", args)
end

function UI:LoadScene(object, args)
    return UI:Component(object, args):addComponent("UI.LoadScene", args)
end

function UI:DebugScene(object, args)
    return UI:Component(object, args):addComponent("UI.DebugScene", args)
end

return UI

