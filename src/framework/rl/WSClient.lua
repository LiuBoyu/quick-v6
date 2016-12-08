
local log = rl.log("WSClient")

-- cc.WEBSOCKET_STATE_CONNECTING = 0
-- cc.WEBSOCKET_STATE_OPEN       = 1
-- cc.WEBSOCKET_STATE_CLOSING    = 2
-- cc.WEBSOCKET_STATE_CLOSED     = 3

-- cc.WEBSOCKET_OPEN     = 0
-- cc.WEBSOCKET_MESSAGE  = 1
-- cc.WEBSOCKET_CLOSE    = 2
-- cc.WEBSOCKET_ERROR    = 3

local WSClient = rl.class("WSClient")

function WSClient:ctor(url)
    self.protocol  = rl.G.WSProtocol
    self.url       = url
    self.req       = {}
    self.keepalive = 60
end

function WSClient:connect(clientid, username, password, callback)
    if self.socket then
        return
    end

    self.callback = callback

    log.debug("CONNECTING: %s", self.url)

    self.socket = cc.WebSocket:create(self.url)

    if self.socket then
        self.socket:registerScriptHandler(function()
            self:send(self.protocol.CONNECT({ clientid = clientid, username = username, password = password, usernameflag = 1, passwordflag = 1, cleansession = 1, keepalive = self.keepalive }))
        end, cc.WEBSOCKET_OPEN)

        self.socket:registerScriptHandler(function(data)
            self:onMessage(data)
        end, cc.WEBSOCKET_MESSAGE)

        self.socket:registerScriptHandler(function()
            log.debug("CLOSED")

            self.socket = nil

            if self.callback then
                local cb = self.callback
                self.callback = nil

                return cb(false)
            end
        end, cc.WEBSOCKET_CLOSE)

        self.socket:registerScriptHandler(function()
            log.error("ERROR")
        end, cc.WEBSOCKET_ERROR)
    end
end

function WSClient:send(data)
    if self.socket then
        self.socket:sendString(data)
    end
end

function WSClient:close()
    if self.socket then
        log.debug("CLOSING")
        self.socket:close()
    end
end

function WSClient:isReady()
    if self.socket then
        if self.socket:getReadyState() == cc.WEBSOCKET_STATE_OPEN then
            return true
        end
    end
end

function WSClient:heartbeat()
    if not self:isReady() then
        return
    end
    self.waitPing = scheduler.performWithDelayGlobal(function()

        self:ping()

        self.waitPong = scheduler.performWithDelayGlobal(function()
            self:close()
        end, self.keepalive/2)

    end, self.keepalive/2)
end

----------------------------------------
-- 内部
----------------------------------------

function WSClient:onMessage(raw)
    local msg = self.protocol.decode(raw, function(pid)
        local req = self.req[pid]
        if req then
            return req.headers.cmdcode, req.headers.cmdname
        end
    end)

    if not msg then
        return log.error("RECV: [%s]", string.len(raw))
    end

    local headers = msg.headers
    local payload = msg.payload

    if     headers.cpt ==  3 then

        if DEBUG_LOG_WEBSOCKET then
            log.debug("RECV: [%s] %s[%s] %s", string.len(raw), headers.cmdname,           0, payload and tostring(payload) or "")
        end

        if self.__onMessage then
            self.__onMessage(headers.cmdname, payload)
        end

    elseif headers.cpt ==  4 then

        local req = self.req[headers.pid]
                    self.req[headers.pid] = nil

        if not req then
            return
        end

        if DEBUG_LOG_WEBSOCKET then
            if headers.errcode then
                log.error("RECV: [%s] %s[%s] %s", string.len(raw), headers.cmdname, headers.pid, headers.errcode)
            else
                log.debug("RECV: [%s] %s[%s] %s", string.len(raw), headers.cmdname, headers.pid, payload and tostring(payload) or "")
            end
        end

        if req.onComplete then
            req.onComplete(headers.cmdname, payload)
        end

    elseif headers.cpt ==  2 then

        local ret

        if headers.retcode == 0 then
            ret = true
            log.debug("CONNECTED")
        else
            ret = false
            log.debug("FAILED")
        end

        if ret then
            self:heartbeat()
        end

        if self.callback then
            local cb = self.callback
            self.callback = nil

            return cb(ret)
        end

    elseif headers.cpt == 13 then

        if self.waitPong then
            scheduler.unscheduleGlobal(self.waitPong)
            self.waitPong = nil
        end

        self:heartbeat()

    end
end

function WSClient:setOnConnect(callback)
    self.__onConnect = callback
end

function WSClient:setOnMessage(callback)
    self.__onMessage = callback
end

function WSClient:setOnClose(callback)
    self.__onClose = callback
end

function WSClient:setOnError(callback)
    self.__onError = callback
end

----------------------------------------
-- 命令
----------------------------------------

function WSClient:publish(cmd, args)
    args.method = "publish"
    return self:__publish(cmd, args)
end

function WSClient:request(cmd, args)
    args.method = "request"
    return self:__publish(cmd, args)
end

function WSClient:requestOnlyOnce(cmd, args)
    args.method = "requestOnlyOnce"
    return self:__publish(cmd, args)
end

function WSClient:cancel(pid)
    self.req[pid] = nil
end

function WSClient:ping()
    self:send(self.protocol.PING())
end

----------------------------------------
-- 内部
----------------------------------------

function WSClient:__publish(cmd, args)
    local qos, payload, encoding, deflate

    if     args.method == "request"         then
        qos = 1
    elseif args.method == "requestOnlyOnce" then
        qos = 2
    end

    if     args.json then
        payload = args.json
        encoding = 0
    elseif args.sp   then
        payload = args.sp
        encoding = 1
    end

    if args.deflate then
        deflate = 1
    end

    local onComplete = args.onComplete

    if not self:isReady() then
        if (qos or 0) > 0 then
            scheduler.performWithDelayGlobal(function()
                if onComplete then
                    onComplete(cmd, { errcode = -1 })
                end
            end, 0)
        end
        return
    end

    local raw, headers = self.protocol.PUBLISH({ cmd = cmd, qos = qos, encoding = encoding, deflate = deflate }, payload)

    if not raw then
        if (qos or 0) > 0 then
            scheduler.performWithDelayGlobal(function()
                if onComplete then
                    onComplete(cmd, { errcode = -9 })
                end
            end, 0)
        end
        return
    end

    if (qos or 0) > 0 then
        self.req[headers.pid] = { headers = headers, onComplete = onComplete }
    end

    if DEBUG_LOG_WEBSOCKET then
        if (qos or 0) > 0 then
            log.debug("SEND: [%s] %s[%s] %s", string.len(raw), headers.cmdname, headers.pid, payload and tostring(payload) or "")
        else
            log.debug("SEND: [%s] %s[%s] %s", string.len(raw), headers.cmdname,           0, payload and tostring(payload) or "")
        end
    end

    self:send(raw)

    return headers.pid or 0
end

return WSClient

