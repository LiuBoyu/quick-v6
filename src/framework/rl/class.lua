
return function(classname)
    local cls = {}

    local mt = { __index = cls }

    function cls.new(...)
        local instance = setmetatable({}, mt)

        if instance.ctor then
            instance:ctor(...)
        end

        return instance
    end

    return cls
end

