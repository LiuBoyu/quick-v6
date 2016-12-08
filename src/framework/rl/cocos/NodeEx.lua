
local Node = cc.Node

function Node:playAction(action, args)
    local args = args or {}

    if type(action) == "string" then

        local ctor = ACTION[act]

        if ctor then
            action = ctor(args.args)
        end
    end

    local action = transition.create(action, args)

    self:runAction(action)

    return action
end

