
local function logging(ctag, tag, fmt, ...)
    local fmt = fmt or ""
    local args = { ... }

    for i = 1, 8 do
        args[i] = tostring(args[i])
    end

    if tag then
        print(table.concat({ "[", ctag, "]", "[", tag, "]", " ", string.format(fmt, unpack(args)) }))
    else
        print(table.concat({ "[", ctag, "]",                " ", string.format(fmt, unpack(args)) }))
    end
end

local function finding(tag)
    repeat

        if LOG[tag] then return LOG[tag] end

        local _, _, ret, dot = string.find(tag, "(.*)([%.|%[|%(]).-$")

        tag = ret

    until not dot
end

local cache = {}

local function DEBUG_TAG(tag)
    if not LOG then return DEBUG_LOG end
    if not tag then return DEBUG_LOG end

    local i = cache[tag]

    if not i then

        i = finding(tag) or DEBUG_LOG

        cache[tag] = i
    end

    return i
end

local function new(tag)
    local log = {}

    function log.debug(fmt, ...)
        if DEBUG_LOG >= 3 and DEBUG_TAG(tag) >= 3 then
            logging("DEBUG", tag, fmt, ...)
        end
    end

    function log.info(fmt, ...)
        if DEBUG_LOG >= 2 and DEBUG_TAG(tag) >= 2 then
            logging("INFO", tag, fmt, ...)
        end
    end

    function log.warn(fmt, ...)
        if DEBUG_LOG >= 1 and DEBUG_TAG(tag) >= 1 then
            logging("WARN", tag, fmt, ...)
        end
    end

    function log.error(fmt, ...)
        if DEBUG_LOG >= 0 and DEBUG_TAG(tag) >= 0 then
            logging("ERROR", tag, fmt, ...)
        end
    end

    return log
end

local log = new()

setmetatable(log, { __call = function(self, tag) return new(tag) end })

return log

