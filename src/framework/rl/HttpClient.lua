
local log = rl.log("HttpClient")

local zlib = require("zlib")

local HTTPMethod = {
    [0] = "GET",
    [1] = "POST",
    [2] = "PUT",
    [3] = "DELETE",
}

local reqid = 1
local reqs = {}

local HttpClient = rl.class("HttpClient")

function HttpClient:ctor(url)
    self.baseUrl = url
    self.cookies = {}
end

----------------------------------------
-- 常用方法
----------------------------------------

function HttpClient:get(endpoint, args)
    args.method = cc.kCCHTTPRequestMethodGET
    return self:send(endpoint, args)
end

function HttpClient:post(endpoint, args)
    args.method = cc.kCCHTTPRequestMethodPOST
    return self:send(endpoint, args)
end

function HttpClient:put(endpoint, args)
    args.method = cc.kCCHTTPRequestMethodPUT
    return self:send(endpoint, args)
end

function HttpClient:delete(endpoint, args)
    args.method = cc.kCCHTTPRequestMethodDELETE
    return self:send(endpoint, args)
end

function HttpClient:download(endpoint, args)
    args.method = cc.kCCHTTPRequestMethodGET

    args.download = true
    args.timeout  = args.timeout or 3600

    return self:send(endpoint, args)
end

----------------------------------------
-- 基础方法
----------------------------------------

function HttpClient:send(endpoint, args)
    local args = args or {}

    args.endpoint = endpoint
    args.url      = args.url or self:internalGetUrl(args)

    -- 处理 高速缓存
    local req

    if not args.forced then
        req = self:internalCheckCache(args)
    end

    if not req then
        -- 创建 Http请求
        req = cc.HTTPRequest:createWithUrl(function(e)
            if e.name == "progress" then
                self:internalProcessProgress(req, e, args)
            else

                -- 注销 Http请求
                reqs[req.id] = nil

                self:internalProcessResponse(req, e, args)
            end
        end, args.url, args.method)
        -- 处理 Http请求
        self:internalProcessRequests(req, args)
    end

    -- 处理 ReqId
    if args.reqid then
        req.id = args.reqid
    else
        req.id = reqid
        reqid  = reqid + 1
    end

    -- 注册 Http请求
    reqs[req.id] = req

    -- 发送 Http请求
    req:start()

    return req.id
end

function HttpClient:cancel(reqid)
    local req = reqs[reqid]

    if req then
        req:cancel()
        req.cancelled = true
    end

    reqs[reqid] = nil
end

----------------------------------------
-- 处理请求 (内部)
----------------------------------------

function HttpClient:internalProcessRequests(req, args)
    -- 处理 PostData
    self:internalProcessPostData(req, args)

    -- 处理 Accept-Encoding
    req:addRequestHeader(string.format("Accept-Encoding: %s", "*"))

    -- 处理 Cookies
    if self.cookies then
        req:setCookieString(network.makeCookieString(self.cookies))
    end

    -- 处理 Timeout
    if args.timeout then
        req:setTimeout(args.timeout)
    end
end

function HttpClient:internalProcessPostData(req, args)
    if args.method == cc.kCCHTTPRequestMethodGET then
        return
    end

    local data, content_type

    -- 处理 数据格式
    data, content_type = self:internalEncodeByType(args)

    -- 处理 数据编码
    data               = self:internalEncodeByData(data, args.content_encoding)

    -- 处理 Req
    if args.content_encoding then
        req:addRequestHeader(string.format("Content-Encoding: %s", args.content_encoding))
    end
    if data          then
        req:addRequestHeader(string.format("Content-Type: %s", content_type))
        req:setPOSTData(data)
    end
end

----------------------------------------
-- 处理响应 (内部)
----------------------------------------

function HttpClient:internalProcessResponse(req, e, args)
    if DEBUG_LOG_HTTP then
        log.debug("[%s]%s >> %s - %s %s", req.id, HTTPMethod[args.method], args.url, e.name, args.retry and string.format("[%s]", args.retry + 1) or "")
    end

    if req.cancelled then
        e.name = "cancelled"
    end

    if e.name == "completed" then

        self:internalProcessResponseData(req, e, args)

        self:internalProcessResponseCookies(req, e, args)
        self:internalProcessResponseOthers(req, e, args)

    else
        if self:internalProcessResponseErrs(req, e, args) then
            return
        end
    end

    e.url = args.url

    if args.onComplete then
        args.onComplete(e)
    end
end

function HttpClient:internalProcessResponseData(req, e, args)
    local headers = req:getResponseHeadersString()

    local data = req:getResponseData()
    local size = req:getResponseDataLength()

    -- 处理 响应状态
    e.status = req:getResponseStatusCode()

    -- 处理 数据头部
    e.headers = self:internalGetResponseHeaders(headers)

    -- 处理 数据编码
    e.data = self:internalDecodeByData(  data, e.headers.content_encoding)
    e.size = string.len(e.data)

    -- 处理 数据格式
    e.res = self:internalDecodeByType(e.data, e.headers.content_type)

    -- 处理 日志输出
    if DEBUG_LOG_HTTP then
        local ContentEncoding = function()
            if e.headers.content_encoding then
                return string.format(", content-encoding: %s [%d%% - %s/%s]", e.headers.content_encoding, size/e.size*100, size, e.size)
            end
            return ""
        end
        local ContentType     = function()
            if e.headers.content_type     then
                return string.format(", content-type: %s", e.headers.content_type)
            end
            return ""
        end
        log.debug("[%s]%s << headers: %s, data: %s%s%s", req.id, e.status, string.len(headers), e.size, ContentEncoding(), ContentType())
    end

    -- 处理 日志输出
    if DEBUG_LOG_HTTP then
        for i, v in ipairs(DEBUG_LOG_HTTP_URLS or {}) do
            if string.find(args.url, v) then

                local data = e.data

                if e.headers.content_type == "application/json"
                or e.headers.content_type == "text/plain" then
                else
                    data = string.bin2hex(data)
                end

                log.debug("HttpResponseHeaders:\n%s", headers)
                log.debug("HttpResponseData:\n%s", data)

                break
            end
        end
    end
end

function HttpClient:internalProcessResponseCookies(req, e, args)
    local cookies = network.parseCookie(req:getCookieString())

    for k, v in pairs(cookies) do
        if not equals(self.cookies[k], v) then

            self.cookies[k] = v

            if DEBUG_LOG_HTTP then
                log.debug("[%s]%s << cookies: %s=%s", req.id, e.status, k, v)
            end
        end
    end
end

function HttpClient:internalProcessResponseOthers(req, e, args)
    -- 处理 高速缓存
    if e.status == 200 and args.cache    then
        if e.headers.content_type == "application/json"
        or e.headers.content_type == "application/x-protobuf"
        or e.headers.content_type == "application/x-www-form-urlencoded" then
            if args.cache.contentType == "application/json" then
                args.cache:save(args.url, e.res)
            end
        else
            if args.cache.contentType == "?"                then
                args.cache:save(args.url, e.res)
            end
        end
    end

    -- 处理 数据长度
    req.dlnow   = req:getResponseDataLength()
    req.dltotal = req:getResponseDataLength()

    e.dlnow   = req.dlnow
    e.dltotal = req.dltotal

    -- 处理 数据下载
    if e.status == 200 and args.download then
        if args.filename then

            e.filename = args.filename
            e.filesize = req:saveResponseData(e.filename)

            if DEBUG_LOG_HTTP then
                log.debug("[%s]%s << file: %s, size: %s", req.id, e.status, e.filename, e.filesize)
            end
        else
            if args.cache then
                if args.cache.storageType == "file" then
                    local v = args.cache:find(args.url)
                    if v then

                        e.filename = args.cache.storagePath .. v.data
                        e.filesize = v.size

                        if DEBUG_LOG_HTTP then
                            log.debug("[%s]%s << file: %s, size: %s", req.id, e.status, e.filename, e.filesize)
                        end
                    end
                end
            end
        end
    end
end

function HttpClient:internalProcessResponseErrs(req, e, args)
    -- 处理 错误信息
    e.err = {
        code = req:getErrorCode(),
        text = req:getErrorMessage(),
    }

    -- 处理 日志输出
    if e.name == "cancelled" then
        if DEBUG_LOG_HTTP then
            log.debug("[%s]%s << [%s] %s", req.id, "ERR", e.err.code, e.err.text)
        end
    else
        log.error("[%s]%s << [%s] %s", req.id, "ERR", e.err.code, e.err.text)
    end

    -- 处理 异常重试
    if e.name == "failed"    then
        args.retry = (args.retry or 0) + 1

        if args.retry < 9 then
            args.reqid = req.id

            self:send(args.endpoint, args)

            return true
        end
    end
end

----------------------------------------
-- 检查缓存 (内部)
----------------------------------------

function HttpClient:internalCheckCache(args)
    -- 检查缓存
    local cache = args.cache

    if not cache then
        return
    end

    -- 读取缓存
    local e = { name = "completed", status = 200 }

    e.url = args.url

    if args.download then
        -- 读取下载
        local v

        if args.filename then
            v = cache:read(args.url)
        else
            v = cache:find(args.url)
        end

        if not v then
            return
        end

        if args.filename then
            e.filename = args.filename
            e.filesize = v.size
            os.write(e.filename, v.data)
        else
            if cache.storageType == "file" then
                e.filename = cache.storagePath .. v.data
                e.filesize = v.size
            else
                -- nothing
            end
        end
    else
        -- 读取数据
        local v = cache:read(args.url)

        if not v then
            return
        end

        e.data = v.data
        e.size = v.size
        e.ts   = v.ts
        e.res  = v.res
    end

    -- 处理请求
    local req = {}

    function req:cancel()
    end

    function req:start()
        scheduler.performWithDelayGlobal(function()
            if req.cancelled then
                return
            end

            if DEBUG_LOG_HTTP then
                log.debug("[%s]%s >> %s - %s %s", req.id, HTTPMethod[args.method], args.url, e.name, "[Cached]")
            end

            if args.onComplete then
                args.onComplete(e)
            end
        end, 0)
    end

    return req
end

----------------------------------------
-- 处理过程 (内部)
----------------------------------------

function HttpClient:internalProcessProgress(req, e, args)
    e.dlnow   = e.dltotal
    e.dltotal = e.total

    if e.dlnow   == req.dlnow then return end
    if e.dltotal == 0         then return end

    req.dlnow   = e.dlnow
    req.dltotal = e.dltotal

    if args.onProgress then
        args.onProgress(e)
    end
end

----------------------------------------
-- 解析地址 (内部)
----------------------------------------

function HttpClient:internalGetUrl(args)
    -- 处理 Url(请求)
    local endpoint = args.endpoint or ""

    for k, v in pairs(args.params or {}) do
        endpoint = string.gsub(endpoint, string.format("{%s}", k), v)
    end

    -- 处理 Url(请求)
    local filter = {}

    for k, v in pairs(args.filter or {}) do
        filter[#filter + 1] = string.format("%s=%s", k, v)
    end

    -- 处理 Url(请求)
    local url = (self.baseUrl or "") .. endpoint

    if #filter > 0 then
        url = url .. "&" .. table.concat(filter, "&")
    end

    return url
end

----------------------------------------
-- 解析头部 (内部)
----------------------------------------

function HttpClient:internalGetResponseHeaders(headers)
    local _, _, content_type, charset = string.find(headers, "Content%-Type: (.-); charset=(.-)[\r\n]")

    if not content_type then
        _, _, content_type = string.find(headers, "Content%-Type: (.-)[\r\n]")
    end

    local _, _, content_encoding = string.find(headers, "Content%-Encoding: (.-)[\r\n]")

    return { content_type = content_type, charset = charset, content_encoding = content_encoding }
end

----------------------------------------
-- 编码解码 (内部)
----------------------------------------

function HttpClient:internalEncodeByType(args)
    local data, t

    if     args.text then
        data = args.text
        t    = "text/plain"

    elseif args.json then
        data = json.encode(args.json)
        t    = "application/json"

    elseif args.data then
        data = args.data
        t    = "application/octet-stream"

    elseif args.form then
        data = nil -- TODO
        t    = "application/x-www-form-urlencoded"

    elseif args.pbuf then
        data = nil -- TODO
        t    = "application/x-protobuf"
    end

    return data, t
end

function HttpClient:internalDecodeByType(data, t)
    if     t == "application/json"                  then
        return json.decode(data)

    elseif t == "application/x-protobuf"            then
        return (data) -- TODO

    elseif t == "application/x-www-form-urlencoded" then
        return (data) -- TODO

    else
        return data
    end
end

function HttpClient:internalEncodeByData(data, encoding)
    if     encoding == "gzip" then

        local deflated, eof, bytes_in, bytes_out = zlib.deflate()(data, "finish")
        return deflated

    elseif encoding == "xt"   then

        -- TODO
        return data

    end
    return data
end

function HttpClient:internalDecodeByData(data, encoding)
    if     encoding == "gzip" then

        local inflated, eof, bytes_in, bytes_out = zlib.inflate()(data)
        return inflated

    elseif encoding == "xt"   then

        -- TODO
        return data

    end
    return data
end

----------------------------------------
-- 异常信息 (全局)
----------------------------------------

local HTTPStatus = {
    [200] = "OK",
    [201] = "CREATED",
    [400] = "BAD_REQUEST",
    [401] = "UNAUTHORIZED",
    [403] = "FORBIDDEN",
    [404] = "NOT_FOUND",
    [405] = "NOT_ALLOWED",
    [500] = "INTERNAL_SERVER_ERROR",
    [501] = "METHOD_NOT_IMPLEMENTED",
    [503] = "SERVICE_UNAVAILABLE",
}

function NetErrMsg(e)
    if e.status then
        local msg = string.format("[%s] %s", e.status, HTTPStatus[e.status] or "")
        if e.data and string.len(e.data) > 0 then
            msg = msg .. " - " .. e.data
        end
        return msg
    end

    if e.err then
        return string.format("[%s] %s", e.err.code or -1, e.err.text or "")
    end

    return "[unknown]"
end

return HttpClient

