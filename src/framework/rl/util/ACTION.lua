
local M = {}

-- Dialog

M["Dialog.OnEnter"] = function(args)

    local act = cc.Sequence:create({
                    cc.ScaleTo:create(0.0, 0.0),
                    cc.ScaleTo:create(1.0, 1.0),
                })

    return cc.ELASTICOUT:create(act)
end

M["Dialog.OnExit"] = function(args)

    local act = cc.Sequence:create({
                    cc.ScaleTo:create(0.0, 1.0),
                    cc.ScaleTo:create(0.5, 0.0),
                })

    return cc.BACKIN:create(act)
end

return M

