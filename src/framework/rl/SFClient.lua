
local log = rl.log("SFClient")

local REQID = 1

local function newReqId()
    local id = REQID ; REQID = REQID + 1 ; if REQID > 65535 then REQID = 1 end ;
    return id
end

local SFClient = rl.class("SFClient")

function SFClient:ctor(args)
    rl.Component(self)
        :addComponent("SDK.SFClient")

    self.protocol = args.protocol or {}
    self.parallel = args.parallel

    self.host = args.host
    self.port = args.port
    self.zone = args.zone

    self.timeout = args.timeout or 10

    self.status = 0 -- 0 closed : 1 connecting : 2 connected

    self.queue = {}
    self.req   = {}

    if DEBUG_LOG_SFS2XAPI then
        self.debug = args.debug or false
        self.log   = args.log   or 2
    end

    scheduler.scheduleGlobal(function()
        local ts1 = os.time()
        local ts0, timeout
        for k, v in pairs(self.req) do
            ts0     = v.ts
            timeout = v.timeout or self.timeout
            if ts0 then
                if (ts1 - ts0) > timeout then
                    self:cancel(v.id, "超时")
                end
            end
        end
    end, 1)

    self:startBySFClientSDK({
        protocol = self.protocol,
        debug    = self.debug,
        log      = self.log,
        callback = function(cmd, payload)
            return self:onMessage(cmd, payload)
        end,
    })
end

function SFClient:connect(callback)
    if self.status < 1 then -- connecting
        self.callback = callback
        self.status   = 1   -- connecting
        self:connectBySFClientSDK({
            host    = self.host,
            port    = self.port,
            zone    = self.zone,
            udpHost = self.host,
            udpPort = self.port,
            debug   = self.debug,
        })
    else
        if callback then scheduler.performWithDelayGlobal(function()
            callback({ success = false })
        end, 0) end
    end
end

function SFClient:close()
    self:disconnectBySFClientSDK()
end

function SFClient:kill()
    self:killConnectionBySFClientSDK()
end

function SFClient:enableLagMonitor(enabled)
    self:enableLagMonitorBySFClientSDK({ enabled = enabled })
end

function SFClient:isConnected()
    return self.status > 1 -- connecting
end

----------------------------------------
-- 事件回调
----------------------------------------

function SFClient:setOnConnect(callback)
    self.__onConnect = callback
end

function SFClient:setOnMessage(callback)
    self.__onMessage = callback
end

function SFClient:setOnRetry(callback)
    self.__onRetry = callback
end

function SFClient:setOnResume(callback)
    self.__onResume = callback
end

function SFClient:setOnClose(callback)
    self.__onClose = callback
end

function SFClient:setOnError(callback)
    self.__onError = callback
end

----------------------------------------
-- 内部函数
----------------------------------------

function SFClient:onMessage(cmd, payload)
    if     cmd == "@connection" then

        if payload.success then
            self.status = 2 -- connected
        else
            self.status = 0 -- closed
        end

        if DEBUG_LOG_SFS2XAPI then
            if payload.success then
                log.debug("连接成功...")
            else
                log.debug("连接失败...")
            end
        end

        if self.callback then
            local cb = self.callback
                       self.callback = nil
            cb(payload)
        end

        if payload.success then
            if self.__onConnect then
                self.__onConnect(payload)
            end
        end

    elseif cmd == "@connectionRetry" then

        self.status = 1 -- connecting

        if DEBUG_LOG_SFS2XAPI then
            log.debug("断线重连...")
        end

        if self.__onRetry then
            self.__onRetry({})
        end

    elseif cmd == "@connectionResume" then

        self.status = 2 -- connected

        if DEBUG_LOG_SFS2XAPI then
            log.debug("断线恢复...")
        end

        if self.__onResume then
            self.__onResume({})
        end

    elseif cmd == "@connectionLost" then

        self.status = 0 -- closed

        if DEBUG_LOG_SFS2XAPI then
            log.debug("连接中断!!!")
        end

        self:cancelAll("断线")

        if self.__onClose then
            self.__onClose(payload)
        end

    elseif cmd == "@connectionAttempHTTP" then

        -- nothing

    elseif cmd == "@pingPong" then

        if DEBUG_LOG_SFS2XAPI then
            log.debug("PONG: %s", payload)
        end

    else
        if (self.protocol[cmd] or {}).request then
            local queue = self:findByQueue(cmd)
            if queue then
                if #queue > 0 then
                    local req = table.remove(queue, 1)

                    if self.req[req.id] then
                        if DEBUG_LOG_SFS2XAPI then
                            log.debug("接收: %s[%s] %s", cmd, req.id, payload and tostring(payload) or "")
                        end

                        self.req[req.id] = nil

                        self:sendByQueue(cmd, queue)

                        if req.onComplete then
                            req.onComplete({ cmd = cmd, payload = payload, status = 200 })
                        end
                    else
                        if DEBUG_LOG_SFS2XAPI then
                            log.debug("忽略: %s[%s] %s", cmd, req.id, payload and tostring(payload) or "")
                        end
                    end
                end
            else
                    local req = self.req[(payload or {})["@"] or 0]

                    if req then
                        self.req[req.id] = nil

                        if DEBUG_LOG_SFS2XAPI then
                            log.debug("接收: %s[%s] %s", cmd, req.id, payload and tostring(payload) or "")
                        end

                        if payload then
                            payload["@"] = nil
                        end

                        if req.onComplete then
                            req.onComplete({ cmd = cmd, payload = payload, status = 200 })
                        end
                    else
                        if DEBUG_LOG_SFS2XAPI then
                            log.debug("忽略: %s[%s] %s", cmd, "?", payload and tostring(payload) or "")
                        end
                    end
            end
        else
            if DEBUG_LOG_SFS2XAPI then
                log.debug("接收: %s[%s] %s", cmd, 0, payload and tostring(payload) or "")
            end
            if self.__onMessage then
                self.__onMessage(cmd, payload)
            end
        end
    end
end

----------------------------------------
-- 常用命令
----------------------------------------

function SFClient:publish(cmd, args)
    local args = args or {}
    args.method = "message"
    return self:send(cmd, args)
end

function SFClient:request(cmd, args)
    local args = args or {}
    args.method = "request"
    return self:send(cmd, args)
end

function SFClient:cancel(id, reason)
    local req = self.req[id]
    if req then
        if DEBUG_LOG_SFS2XAPI then
            log.debug("取消(%s): %s[%s] %s", reason or "手动", req.cmd, id, req.payload and tostring(req.payload) or "")
        end

        self.req[id] = nil

        local queue = self:findByQueue(req.cmd)
        if queue then
            if #queue > 0 then
                if queue[1].id == id then
                    self:sendByQueue(req.cmd, queue)
                else
                    for i, v in ipairs(queue) do
                        if v.id == id then
                            table.remove(queue, i)
                            break
                        end
                    end
                end
            end
        end

        if req.onComplete then
            req.onComplete({ cmd = req.cmd, status = -1 })
        end
    end
end

function SFClient:cancelAll(reason)
    for id, req in pairs(self.req) do
        if DEBUG_LOG_SFS2XAPI then
            log.debug("取消(%s): %s[%s] %s", reason or "手动", req.cmd, id, req.payload and tostring(req.payload) or "")
        end

        self.req[id] = nil

        if req.onComplete then
            req.onComplete({ cmd = req.cmd, status = -1 })
        end
    end
    self.queue = {}
end

----------------------------------------
-- 内部函数
----------------------------------------

function SFClient:send(cmd, args)
    local args = args or {}

    local method = args.method or "message"

    local payload = args.payload
    local onComplete = args.onComplete

    local timeout = args.timeout

    if self.status < 2 then -- connected
        if method == "request" then
            if onComplete then scheduler.performWithDelayGlobal(function()
                onComplete({ cmd = cmd, status = -1 })
            end, 0) end
        end
        return
    end

    local id

    if method == "request" then
                 id  = newReqId()
        self.req[id] = { cmd = cmd, id = id, payload = payload, onComplete = onComplete, timeout = timeout }

        local queue = self:findByQueue(cmd)
        if queue then

            queue[#queue + 1] = self.req[id]

            if #queue > 1 then
                if DEBUG_LOG_SFS2XAPI then
                    log.debug("队列: %s[%s] %s", cmd, id, payload and tostring(payload) or "")
                end
                return id
            end
        else
            if not payload then
                                       payload = {}
                self.req[id].payload = payload
            end
            payload["@"] = id
        end
    end

    if DEBUG_LOG_SFS2XAPI then
        log.debug("发送: %s[%s] %s", cmd, id or 0, payload and tostring(payload) or "")
    end

    if id then
        self.req[id].ts = os.time()
    end

    self:sendBySFClientSDK(cmd, payload)
    return id or 0
end

----------------------------------------
-- 内部函数
----------------------------------------

function SFClient:findByQueue(cmd)
    if string.sub(cmd, 1, 1) == "@" or not self.parallel then
        local queue = self.queue[cmd]
        if not queue then
                              queue = {}
            self.queue[cmd] = queue
        end
        return queue
    end
end

function SFClient:sendByQueue(cmd, queue)
    while #queue > 0 do
        local req = queue[1]

        if self.req[req.id] then
            if DEBUG_LOG_SFS2XAPI then
                log.debug("发送: %s[%s] %s", req.cmd, req.id, req.payload and tostring(req.payload) or "")
            end

            req.ts = os.time()
            self:sendBySFClientSDK(req.cmd, req.payload)

            return
        else
            table.remove(queue, 1)
        end
    end
end

return SFClient

