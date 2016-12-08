
local pack = require("pack")
local string_pack   = string.pack
local string_unpack = string.unpack

local zlib = require("zlib")
local zlib_deflate = zlib.deflate
local zlib_inflate = zlib.inflate

local json = require("cjson")
local json_encode = json.encode
local json_decode = json.decode

local concat = table.concat

local format = string.format
local strsub = string.sub
local strlen = string.len
local gsub   = string.gsub
local byte   = string.byte

local floor  = math.floor

local tostring = tostring
local strhex = function(s) return gsub(s, "(.)", function(x) return format("%02X", byte(x)) end) end

local print = print
local pcall = pcall
local pairs = pairs
local type  = type

----------------------------------------
-- 协议
----------------------------------------

-- Headers:: Flags(1byte):CmdCode(2byte):[CmdName(2byte)]:[Pid(2byte)]:[Flags(1byte)]
-- Payload:: Blob

local CPCfg = {
    [ 1] = { 0, 1, 0 }, --  1 CONNECT
    [ 2] = { 0, 1, 0 }, --  2 CONNACK
    [ 3] = { 1, 1, 2 }, --  3 PUBLISH
    [ 4] = { 0, 2, 2 }, --  4 PUBACK
    [ 5] = { 0, 2, 2 }, --  5 PUBREC
    [ 6] = { 2, 2, 0 }, --  6 PUBREL
    [ 7] = { 0, 2, 0 }, --  7 PUBCOMP
    [ 8] = { 2, 2, 1 }, --  8 SUBSCRIBE
    [ 9] = { 0, 2, 1 }, --  9 SUBACK
    [10] = { 2, 2, 1 }, -- 10 UNSUBSCRIBE
    [11] = { 0, 2, 0 }, -- 11 UNSUBACK
    [12] = { 0, 0, 0 }, -- 12 PINGREQ
    [13] = { 0, 0, 0 }, -- 13 PINGRESP
    [14] = { 0, 0, 0 }, -- 14 DISCONNECT
}

-- cpc[1]  QoS      0 no  1 all       2 qos=1
-- cpc[2]  Headers  0 no  1 custom    2 pid(only)
-- cpc[3]  Payload  0 no  1 required  2 optional

----------------------------------------
-- 初始
----------------------------------------

local DEBUG = 0
local ERROR = function(code) if DEBUG > 0 then print(code) end end

local CmdCfgByCode
local CmdCfgByName

local function initCmdCfg(cmdcfg)
    CmdCfgByCode = {}
    CmdCfgByName = {}

    for k, v in pairs(cmdcfg) do
        v.name = k
    end

    for k, v in pairs(cmdcfg) do
        CmdCfgByCode[v.code] = v
        CmdCfgByName[v.name] = v
    end
end

local sp, sp_encode, sp_encode_req, sp_encode_res, sp_pack, sp_decode, sp_decode_req, sp_decode_res, sp_unpack

local function initSPCfg(sproto, spcfg)
    sp = sproto.parse(spcfg)
    sp_encode, sp_encode_req, sp_encode_res, sp_pack   = sp.encode, sp.request_encode, sp.response_encode, sp.pack
    sp_decode, sp_decode_req, sp_decode_res, sp_unpack = sp.decode, sp.request_decode, sp.response_decode, sp.unpack
end

----------------------------------------
-- 工具
----------------------------------------

local PID = 1

local function newpid()
    local pid = PID ; PID = PID + 1 ; if PID > 65535 then PID = 1 end ;
    return pid
end

----------------------------------------
-- 工具
----------------------------------------

local function getcmd(headers, cpt)
    local cmdcode, cmdname, cmd, encoding, deflate = headers.cmdcode, headers.cmdname, headers.cmd, headers.encoding, headers.deflate
    local cfg, ref, rpc
    local cpt = cpt or headers.cpt

    cmdname = cmdname or cmd

    if cmdname then
        cfg = CmdCfgByName[cmdname]
        if cfg then
            cmdcode = cfg.code
        else
            cmdcode = 0
        end
    else
        cfg = CmdCfgByCode[cmdcode]
        if cfg then
            cmdname = cfg.name
        end
    end

    if encoding == 1 then                                                                 if not cfg then return cmdcode, cmdname, 0, deflate end ;
        ref = cfg.sp                                                                    ; if not ref then return cmdcode, cmdname, 0, deflate end ;
    end

    if ref then
        if cfg.rpc then
            if     cpt == 3 then rpc = 1
            elseif cpt == 4
                or cpt == 5 then rpc = 2
            end
        else
            rpc = 0
        end
    end

    return cmdcode, cmdname, encoding, deflate, ref, rpc
end

----------------------------------------
-- 工具
----------------------------------------

local function dumpdecode(headers, payload, raw, hl, pl)
    local tbl = {}

    if headers then
        tbl[#tbl+1] = format("%s", tostring(headers))
        tbl[#tbl+1] = format("[%s]:%s", hl, strhex(strsub(raw,1,hl)))
    end

    if payload then
        tbl[#tbl+1] = format("%s", tostring(payload))
        tbl[#tbl+1] = format("[%s]:%s", pl, strhex(strsub(raw,hl+1)))
    end

    print( "decode: " .. concat(tbl, ", ") )
end

local function dumpencode(headers, payload, rh, rp)
    local tbl = {}

    if headers then
        tbl[#tbl+1] = format("%s", tostring(headers))
        tbl[#tbl+1] = format("[%s]:%s", strlen(rh), strhex(rh))
    end

    if payload then
        tbl[#tbl+1] = format("%s", tostring(payload))
        tbl[#tbl+1] = format("[%s]:%s", strlen(rp), strhex(rp))
    end

    print( "encode: " .. concat(tbl, ", ") )
end

----------------------------------------
-- 解码
----------------------------------------

local function decode_headers_flags(flags)
    local retain = flags %  2; flags = flags - retain; flags = floor(flags/ 2); if retain == 0 then retain = nil end;
    local qos    = flags %  4; flags = flags - qos   ; flags = floor(flags/ 4); if qos    == 0 then qos    = nil end;
    local dup    = flags %  2; flags = flags - dup   ; flags = floor(flags/ 2); if dup    == 0 then dup    = nil end;
    local cpt    = flags % 16; flags = flags - cpt   ; flags = floor(flags/16);

    return cpt, dup, qos, retain
end

local function decode_payload_flags(flags)
    local reserved = flags % 16; flags = flags - reserved; flags = floor(flags/16);
    local deflate  = flags %  2; flags = flags - deflate ; flags = floor(flags/ 2); if deflate == 0 then deflate = nil end;
    local encoding = flags %  8; flags = flags - encoding; flags = floor(flags/ 8);

    return encoding, deflate
end

local function decode_connect_flags(flags)
    local reserved     = flags % 2; flags = flags - reserved    ; flags = floor(flags/2);
    local cleansession = flags % 2; flags = flags - cleansession; flags = floor(flags/2); if cleansession == 0 then cleansession = nil end;
    local willflag     = flags % 2; flags = flags - willflag    ; flags = floor(flags/2); if willflag     == 0 then willflag     = nil end;
    local willqos      = flags % 2; flags = flags - willqos     ; flags = floor(flags/2); if willqos      == 0 then willqos      = nil end;
    local willretain   = flags % 4; flags = flags - willretain  ; flags = floor(flags/4); if willretain   == 0 then willretain   = nil end;
    local passwordflag = flags % 2; flags = flags - passwordflag; flags = floor(flags/2); if passwordflag == 0 then passwordflag = nil end;
    local usernameflag = flags % 2; flags = flags - usernameflag; flags = floor(flags/2); if usernameflag == 0 then usernameflag = nil end;

    return usernameflag, passwordflag, willretain, willqos, willflag, cleansession
end

----------------------------------------
-- 编码
----------------------------------------

local function encode_headers_flags(cpt, dup, qos, retain)
    return cpt * 16 + (dup or 0) * 8 + (qos or 0) * 2 + (retain or 0)
end

local function encode_payload_flags(encoding, deflate)
    return encoding * 32 + (deflate or 0) * 16
end

local function encode_connect_flags(usernameflag, passwordflag, willretain, willqos, willflag, cleansession)
    return (usernameflag or 0) * 128 + (passwordflag or 0) * 64 + (willretain or 0) * 16 + (willqos or 0) * 8 + (willflag or 0) * 4 + (cleansession or 0) * 2
end

----------------------------------------
-- 解码
----------------------------------------

local function decode_payload(raw, hl, pl, headers)
    local encoding, deflate, ref, rpc = headers.encoding, headers.deflate, headers.ref, headers.rpc

    local offset, ok, payload

    offset, payload = string_unpack(raw, ">A" .. pl, hl + 1)                            ; if not payload then return ERROR(2200) end ;

    if deflate == 1 then
            ok, payload = pcall(zlib_inflate()        , payload)                        ; if not ok      then return ERROR(2210) end ;
    end

    if     encoding == 0 then -- json
            ok, payload = pcall(json_decode           , payload)                        ; if not ok      then return ERROR(2220) end ;
    elseif encoding == 1 then -- sp
            ok, payload = pcall(sp_unpack             , payload)                        ; if not ok      then return ERROR(2230) end ;
        if     rpc == 0 then
            ok, payload = pcall(sp_decode    , sp, ref, payload)                        ; if not ok      then return ERROR(2231) end ;
        elseif rpc == 1 then
            ok, payload = pcall(sp_decode_req, sp, ref, payload)                        ; if not ok      then return ERROR(2232) end ;
        elseif rpc == 2 then
            ok, payload = pcall(sp_decode_res, sp, ref, payload)                        ; if not ok      then return ERROR(2233) end ;
        end
    elseif encoding == 6 then -- no
    else
        return ERROR(2290)
    end

    return payload
end

----------------------------------------
-- 解码
----------------------------------------

local function decode_headers(raw)
    local headers, offset, hflags, pflags, cflags, cl = {}

    -- part 1
    offset, hflags = string_unpack(raw, ">b")                                           ; if not hflags               then return ERROR(2100) end ;
    headers.cpt, headers.dup, headers.qos, headers.retain = decode_headers_flags(hflags)

    -- part 2
    local cpt = headers.cpt
    local cpc = CPCfg[cpt]                                                              ; if not cpc                  then return ERROR(2101) end ;

    if     cpt == 1 then
            offset, cl                   = string_unpack(raw, ">H", offset)             ; if not cl                   then return ERROR(2110) end ;
            offset, headers.protocolname = string_unpack(raw, ">A" .. cl, offset)       ; if not headers.protocolname then return ERROR(2110) end ;
            offset, headers.protocolcode = string_unpack(raw, ">b", offset)             ; if not headers.protocolcode then return ERROR(2111) end ;
            offset, cflags               = string_unpack(raw, ">b", offset)             ; if not cflags               then return ERROR(2112) end ;
            headers.usernameflag, headers.passwordflag, headers.willretain, headers.willqos, headers.willflag, headers.cleansession = decode_connect_flags(cflags)
            offset, headers.keepalive    = string_unpack(raw, ">H", offset)             ; if not headers.keepalive    then return ERROR(2113) end ;
        if headers.keepalive == 0 then
                    headers.keepalive    = nil
        end
            offset, cl                   = string_unpack(raw, ">H", offset)             ; if not cl                   then return ERROR(2114) end ;
            offset, headers.clientid     = string_unpack(raw, ">A" .. cl, offset)       ; if not headers.clientid     then return ERROR(2114) end ;
        if (headers.willflag     or 0) == 1 then
            offset, cl                   = string_unpack(raw, ">H", offset)             ; if not cl                   then return ERROR(2115) end ;
            offset, headers.willtopic    = string_unpack(raw, ">A" .. cl, offset)       ; if not headers.willtopic    then return ERROR(2115) end ;
            offset, cl                   = string_unpack(raw, ">H", offset)             ; if not cl                   then return ERROR(2116) end ;
            offset, headers.willmessage  = string_unpack(raw, ">A" .. cl, offset)       ; if not headers.willmessage  then return ERROR(2116) end ;
        end
        if (headers.usernameflag or 0) == 1 then
            offset, cl                   = string_unpack(raw, ">H", offset)             ; if not cl                   then return ERROR(2117) end ;
            offset, headers.username     = string_unpack(raw, ">A" .. cl, offset)       ; if not headers.username     then return ERROR(2117) end ;
        end
        if (headers.passwordflag or 0) == 1 then
            offset, cl                   = string_unpack(raw, ">H", offset)             ; if not cl                   then return ERROR(2118) end ;
            offset, headers.password     = string_unpack(raw, ">A" .. cl, offset)       ; if not headers.password     then return ERROR(2118) end ;
        end
    elseif cpt == 2 then
            offset, headers.sp      = string_unpack(raw, ">b", offset)                  ; if not headers.sp           then return ERROR(2120) end ;
            offset, headers.retcode = string_unpack(raw, ">b", offset)                  ; if not headers.retcode      then return ERROR(2121) end ;
    elseif cpt == 3 then
            offset, headers.cmdcode = string_unpack(raw, ">H", offset)                  ; if not headers.cmdcode      then return ERROR(2130) end ;
        if headers.cmdcode == 0 then
            offset, cl              = string_unpack(raw, ">H", offset)                  ; if not cl                   then return ERROR(2131) end ;
            offset, headers.cmdname = string_unpack(raw, ">A" .. cl, offset)            ; if not headers.cmdname      then return ERROR(2132) end ;
        end
        if (headers.qos or 0) > 0 then
            offset, headers.pid = string_unpack(raw, ">H", offset)                      ; if not headers.pid          then return ERROR(2133) end ;
        end
    else
        if cpc[2] == 2 then
            offset, headers.pid = string_unpack(raw, ">H", offset)                      ; if not headers.pid          then return ERROR(2140) end ;
        end
    end

    if offset > strlen(raw) then
        return headers, offset-1, 0
    end

    -- part 3
    offset, pflags = string_unpack(raw, ">b", offset)                                   ; if not pflags               then return ERROR(2150) end ;
    headers.encoding, headers.deflate = decode_payload_flags(pflags)

    -- part 4
    if headers.encoding == 7 then
        offset, headers.errcode = string_unpack(raw, ">H", offset)                      ; if not headers.errcode      then return ERROR(2160) end ;
        return headers, offset-1, 0
    end

    return headers, offset-1, strlen(raw)-offset+1
end

----------------------------------------
-- 解码
----------------------------------------

local function decode(raw, reqcmd)
    local headers, payload, hl, pl, cpt, encoding, deflate

        headers, hl, pl = decode_headers(raw)                                           ; if not headers         then return             end ;

    cpt = headers.cpt

        if cpt == 4 or cpt == 5 then
            headers.cmdcode, headers.cmdname = reqcmd(headers.pid)
        end

    if pl > 0 then

        if cpt == 3 or cpt == 4 or cpt == 5 then
            headers.cmdcode, headers.cmdname, encoding, deflate, headers.ref, headers.rpc = getcmd(headers)
        end

        payload = decode_payload(raw, hl, pl, headers)                                  ; if not payload         then return             end ;
    end

    -- if DEBUG > 0 then
        dumpdecode(headers, payload, raw, hl, pl)
    -- end

    return { headers = headers, payload = payload }
end

----------------------------------------
-- 编码
----------------------------------------

local function encode_payload(headers, payload)
    local encoding, deflate, ref, rpc = headers.encoding, headers.deflate, headers.ref, headers.rpc

    local ok

    if     encoding == 0 then -- json
            ok, payload = pcall(json_encode           , payload)                        ; if not ok then return ERROR(1220) end ;
    elseif encoding == 1 then -- sp
        if     rpc == 0 then
            ok, payload = pcall(sp_encode    , sp, ref, payload)                        ; if not ok then return ERROR(1230) end ;
        elseif rpc == 1 then
            ok, payload = pcall(sp_encode_req, sp, ref, payload)                        ; if not ok then return ERROR(1231) end ;
        elseif rpc == 2 then
            ok, payload = pcall(sp_encode_res, sp, ref, payload)                        ; if not ok then return ERROR(1232) end ;
        end
            ok, payload = pcall(sp_pack               , payload)                        ; if not ok then return ERROR(1233) end ;
    elseif encoding == 6 then -- no
            ok, payload = (type(payload) == "string") , payload                         ; if not ok then return ERROR(1280) end ;
    else
        return ERROR(1290)
    end

    if deflate == 1 then
            ok, payload = pcall(zlib_deflate(), payload, "finish")                      ; if not ok then return ERROR(1210) end ;
    end

    return string_pack(">A", payload)
end

----------------------------------------
-- 编码
----------------------------------------

local function encode_headers(headers, payload)
    local cpt = headers.cpt                                                             ; if not cpt                  then return ERROR(2100) end ;
    local cpc = CPCfg[cpt]                                                              ; if not cpc                  then return ERROR(2101) end ;

    local tbl = {}

    -- part 1
    if     cpc[1] == 1 then
        tbl[#tbl+1] = string_pack(">b", encode_headers_flags(headers.cpt, headers.dup, headers.qos, headers.retain))
    elseif cpc[1] == 2 then
        tbl[#tbl+1] = string_pack(">b", encode_headers_flags(cpt, 0, 1, 0))
    else
        tbl[#tbl+1] = string_pack(">b", encode_headers_flags(cpt, 0, 0, 0))
    end

    -- part 2
    if     cpt == 1 then                                                                  if not headers.protocolname then return ERROR(2110) end ;
            tbl[#tbl+1] = string_pack(">H", strlen(headers.protocolname))
            tbl[#tbl+1] = string_pack(">A", headers.protocolname)                       ; if not headers.protocolcode then return ERROR(2111) end ;
            tbl[#tbl+1] = string_pack(">b", headers.protocolcode)
            tbl[#tbl+1] = string_pack(">b", encode_connect_flags(headers.usernameflag, headers.passwordflag, headers.willretain, headers.willqos, headers.willflag, headers.cleansession))
            tbl[#tbl+1] = string_pack(">H", headers.keepalive or 0)                     ; if not headers.clientid     then return ERROR(2112) end ;
            tbl[#tbl+1] = string_pack(">H", strlen(headers.clientid))
            tbl[#tbl+1] = string_pack(">A", headers.clientid)
        if (headers.willflag     or 0) == 1 then                                          if not headers.willtopic    then return ERROR(2113) end ;
            tbl[#tbl+1] = string_pack(">H", strlen(headers.willtopic))
            tbl[#tbl+1] = string_pack(">A", headers.willtopic)                          ; if not headers.willmessage  then return ERROR(2114) end ;
            tbl[#tbl+1] = string_pack(">H", strlen(headers.willmessage))
            tbl[#tbl+1] = string_pack(">A", headers.willmessage)
        end
        if (headers.usernameflag or 0) == 1 then                                          if not headers.username     then return ERROR(2115) end ;
            tbl[#tbl+1] = string_pack(">H", strlen(headers.username))
            tbl[#tbl+1] = string_pack(">A", headers.username)
        end
        if (headers.passwordflag or 0) == 1 then                                          if not headers.password     then return ERROR(2116) end ;
            tbl[#tbl+1] = string_pack(">H", strlen(headers.password))
            tbl[#tbl+1] = string_pack(">A", headers.password)
        end
    elseif cpt == 2 then                                                                  if not headers.sp           then return ERROR(2120) end ;
            tbl[#tbl+1] = string_pack(">b", headers.sp)                                 ; if not headers.retcode      then return ERROR(2121) end ;
            tbl[#tbl+1] = string_pack(">b", headers.retcode)
    elseif cpt == 3 then                                                                  if not headers.cmdcode      then return ERROR(2130) end ;
        if headers.cmdcode == 0 then                                                      if not headers.cmdname      then return ERROR(2131) end ;
            tbl[#tbl+1] = string_pack(">H", headers.cmdcode)
            tbl[#tbl+1] = string_pack(">H", strlen(headers.cmdname))
            tbl[#tbl+1] = string_pack(">A", headers.cmdname)
        else
            tbl[#tbl+1] = string_pack(">H", headers.cmdcode)
        end
        if (headers.qos or 0) > 0 then                                                    if not headers.pid          then return ERROR(2132) end ;
            tbl[#tbl+1] = string_pack(">H", headers.pid)
        end
    else
        if cpc[2] == 2 then                                                               if not headers.pid          then return ERROR(2140) end ;
            tbl[#tbl+1] = string_pack(">H", headers.pid)
        end
    end

    -- part 3
    if headers.errcode then
        tbl[#tbl+1] = string_pack(">b", encode_payload_flags(7, 0))
        tbl[#tbl+1] = string_pack(">H", headers.errcode)
        return concat(tbl)
    end

    -- part 4
    if     cpc[3] == 1 then
        if payload then
            tbl[#tbl+1] = string_pack(">b", encode_payload_flags(headers.encoding, headers.deflate))
        else
            return
        end
    elseif cpc[3] == 2 then
        if payload then
            tbl[#tbl+1] = string_pack(">b", encode_payload_flags(headers.encoding, headers.deflate))
        end
    end

    return concat(tbl)
end

----------------------------------------
-- 编码
----------------------------------------

local function encode(headers, payload)
    local rh = encode_headers(headers, payload)                                         ; if not rh then return end ;
    local rp

    if payload then
        rp = encode_payload(headers, payload)                                           ; if not rp then return end ;
    end

    if DEBUG > 0 then
        dumpencode(headers, payload, rh, rp)
    end

    if payload then
        return rh .. rp, headers
    else
        return rh      , headers
    end
end

----------------------------------------
-- 命令
----------------------------------------

local function CONNECT(headers)
    return encode({ cpt = 1, protocolname = "MQTT-RL", protocolcode = 0, usernameflag = headers.usernameflag, passwordflag = headers.passwordflag, willretain = headers.willretain, willqos = headers.willqos, willflag = headers.willflag, cleansession = headers.cleansession, keepalive = headers.keepalive, clientid = headers.clientid and tostring(headers.clientid) or nil, willtopic = headers.willtopic, willmessage = headers.willmessage, username = headers.username and tostring(headers.username) or nil, password = headers.password and tostring(headers.password) or nil })
end

local function CONNACK(headers)
    return encode({ cpt = 2, sp = headers.sp, retcode = headers.retcode })
end

local function PUBLISH(headers, payload)
    local cmdcode, cmdname, encoding, deflate, ref, rpc = getcmd(headers, 3)

    local pid

    if (headers.qos or 0) > 0 then
        pid = newpid()
    end

    return encode({ cpt = 3, dup = headers.dup, qos = headers.qos, retain = headers.retain, cmdcode = cmdcode, cmdname = cmdname, pid = pid, encoding = encoding or 0, deflate = deflate, ref = ref, rpc = rpc }, payload)
end

local function PUBACK(headers, payload, errcode)
    local cmdcode, cmdname, encoding, deflate, ref, rpc = getcmd(headers, 4)

    if errcode then
        encoding, deflate, ref, rpc = 7, nil, nil, nil
    end

    return encode({ cpt = 4, errcode = errcode, cmdcode = cmdcode, cmdname = cmdname, pid = headers.pid, encoding = encoding, deflate = deflate, ref = ref, rpc = rpc }, payload)
end

local function PUBREC(headers, payload, errcode)
    local cmdcode, cmdname, encoding, deflate, ref, rpc = getcmd(headers, 5)

    if errcode then
        encoding, deflate, ref, rpc = 7, nil, nil, nil
    end

    return encode({ cpt = 5, errcode = errcode, cmdcode = cmdcode, cmdname = cmdname, pid = headers.pid, encoding = encoding, deflate = deflate, ref = ref, rpc = rpc }, payload)
end

local function PUBREL(headers)
    return encode({ cpt = 6, pid = headers.pid, qos = 1 })
end

local function PUBCOMP(headers)
    return encode({ cpt = 7, pid = headers.pid })
end

local function PING()
    return encode({ cpt = 12 })
end

local function PONG()
    return encode({ cpt = 13 })
end

local function DISCONNECT()
    return encode({ cpt = 14 })
end

----------------------------------------
-- 构建
----------------------------------------

local M = {}

M.encode     = encode
M.decode     = decode

M.CONNECT    = CONNECT
M.CONNACK    = CONNACK
M.PUBLISH    = PUBLISH
M.PUBACK     = PUBACK
M.PUBREC     = PUBREC
M.PUBREL     = PUBREL
M.PUBCOMP    = PUBCOMP
M.PING       = PING
M.PONG       = PONG
M.DISCONNECT = DISCONNECT

M.init = function(args)

    initCmdCfg(args.cmdcfg)
    initSPCfg(args.sproto, args.spcfg)

    return M
end

return M

