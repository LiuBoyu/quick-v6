
local lfs = require"lfs"

----------------------------------------
-- 常用操作 (目录) (存在Android兼容性问题) -- TODO 需要修改，只能通用于可写目录
----------------------------------------

function os.ls(filepath, basepath)
    local filepath = filepath or ""
    local basepath = basepath or ""

    if not os.exists(basepath .. filepath) then return {} end

    local list = {}

    local function __ls(filepath, basepath)
        local iter, dir_obj = lfs.dir(basepath .. filepath)
        while true do
            local dir = iter(dir_obj)
            if dir == nil then break end
            if dir ~= "." and dir ~= ".." then
                local curDir = filepath .. dir
                local mode = lfs.attributes(basepath .. curDir, "mode")
                if mode == "directory" then
                    __ls(curDir .. "/", basepath)
                end
                if mode == "file"      then
                    if string.sub(dir, 1, 1) ~= "." then
                        list[#list + 1] = curDir
                    end
                end
            end
        end
    end
    __ls(filepath, basepath)

    return list
end

----------------------------------------
-- 常用操作 (文件)
----------------------------------------

function os.cp(src, dst)
    local data = os.read(src)
    if not data then return end

    local ok = os.mkdir(os.filepath(dst))
    if not ok then return end

    return os.write(dst, data)
end

function os.mv(src, dst)
    local ok = os.mkdir(os.filepath(dst))
    if not ok then return end

    return os.rename(src, dst)
end

function os.rm(src)
    return os.remove(src)
end

----------------------------------------
-- 常用操作 (文件)
----------------------------------------

function os.filepath(fullpath)
    local i, j = string.find(fullpath, ".*/"); if not i or not j then return          end
    return string.sub(fullpath, i, j)
end

function os.filename(fullpath)
    local i, j = string.find(fullpath, ".*/"); if not i or not j then return fullpath end
    if j < string.len(fullpath) then
        return string.sub(fullpath, j+1)
    end
end

----------------------------------------
-- 写入
----------------------------------------

function os.write(fullpath, data)
    local file = io.open(fullpath, "wb")
    if not file then return end

    local ok = file:write(data); file:flush(); file:close()
    return ok
end

function os.safewrite(fullpath, data)
    local ok = os.write(fullpath .. ".~t~", data)
    if not ok then return end

    return os.mv(fullpath .. ".~t~", fullpath)
end

----------------------------------------
-- 加载lua
----------------------------------------

function os.loadfile(fullpath)
    local s = os.read(fullpath)
    if not s then return end

    return os.loadstring(s)
end

function os.loadstring(s)
    local f = loadstring(s)
    if not f then return end

    return f()
end

----------------------------------------
-- Cocos 相关
----------------------------------------

local function checkfilename(filename)
    if string.sub(filename, -1) == "/" then
        return string.sub(filename, 1, -2)
    end
    return filename
end

local function checkfilepath(filepath)
    if string.sub(filepath, -1) ~= "/" then
        return filepath .. "/"
    end
    return filepath
end

function os.fullpath(filename)
    return cc.FileUtils:getInstance():fullPathForFilename(checkfilename(filename))
end

function os.exists(filename)
    return cc.FileUtils:getInstance():isFileExist(checkfilename(filename))
end

function os.mkdir(filepath)
    return cc.FileUtils:getInstance():createDirectory(checkfilepath(filepath))
end

function os.rmdir(filepath)
    return cc.FileUtils:getInstance():removeDirectory(checkfilepath(filepath))
end

function os.read(filename)
    return cc.HelperFunc:getFileData(filename)
end

----------------------------------------
-- MD5 & Size
----------------------------------------

function os.filesize(fullpath)
    if cc.Application:getInstance():getTargetPlatform() == 3 then -- android
        if string.sub(fullpath, 1, 1) ~= "/" then -- relative path
            local s = os.read(fullpath)
            return string.len(s)
        end
    end
    return cc.FileUtils:getInstance():getFileSize(fullpath)
end

function os.md5file(fullpath)
    if cc.Application:getInstance():getTargetPlatform() == 3 then -- android
        if string.sub(fullpath, 1, 1) ~= "/" then -- relative path
            local s = os.read(fullpath)
            return os.md5(s)
        end
    end
    return cc.Crypto:MD5File(fullpath)
end

function os.md5(s)
    return cc.Crypto:MD5(s, string.len(s), false)
end

----------------------------------------
-- 扩展函数 - 深度比较
----------------------------------------

function equals(t1, t2)
    local e1 = type(t1)
    local e2 = type(t2)

    if e1 ~= e2 then
        return false
    end

    if e1 ~= "table" then
        return t1 == t2
    end

    for k1     in pairs(t1) do
        if t2[k1] == nil then return false end
    end
    for k2     in pairs(t2) do
        if t1[k2] == nil then return false end
    end
    for k1, v1 in pairs(t1) do
        if not equals(v1, t2[k1]) then
            return false
        end
    end

    return true
end

----------------------------------------
-- 扩展函数 - 二进制转换
----------------------------------------

function string.bin2hex(s)
    return string.gsub(s, "(.)", function(x) return string.format("%02X", string.byte(x)) end)
end

local h2b = {
    ["0"] = 0,
    ["1"] = 1,
    ["2"] = 2,
    ["3"] = 3,
    ["4"] = 4,
    ["5"] = 5,
    ["6"] = 6,
    ["7"] = 7,
    ["8"] = 8,
    ["9"] = 9,
    ["A"] = 10,
    ["B"] = 11,
    ["C"] = 12,
    ["D"] = 13,
    ["E"] = 14,
    ["F"] = 15,
}

function string.hex2bin(h)
    return string.gsub(h, "(.)(.)", function(h, l) return string.char(h2b[h]*16+h2b[l]) end)
end

function string.startswith(str, substr)
    if substr == string.sub(str, 1, string.len(substr)) then
        return true
    end
    return false
end

function string.endswith(str, substr)
    if substr == string.sub(str,   -string.len(substr)) then
        return true
    end
    return false
end

----------------------------------------
-- 扩展函数 - 数字格式化
----------------------------------------

local function modf(v)
    local a, b = math.modf(v)
    b = math.floor(b*100)

    if b % 10 > 4 then
        b = math.floor(b/10) + 1
    else
        b = math.floor(b/10)
    end
    if b > 9 then
        b = b - 10
        a = a + 1
    end

    return a, b
end

function string.formatnumbershorts(v)
    local a, b

    if     v >= 100000000 then
        v = v / 10000000
        a, b = modf(v)

        return string.formatnumberthousands(a) .. "." .. b .. "Cr"
    elseif v >= 1000000 then
        v = v / 100000
        a, b = modf(v)

        return string.formatnumberthousands(a) .. "." .. b .. "L"
    else
        return string.formatnumberthousands(v)
    end
end

----------------------------------------
-- 扩展函数 - 打印表
----------------------------------------

local __tostring = tostring

function tostring(t)
    if type(t) ~= "table" then return __tostring(t) end

    local function __strlen(tbl)
        local len = 0
        for i, v in ipairs(tbl) do
            len = len + string.len(tbl[i])
        end
        return len
    end

    local function __concat(tbl, n)
        local i = "\n" .. string.rep("\t", n - 1)

        if __strlen(tbl) > 160 then
            return "{" .. i .. "\t" .. table.concat(tbl, "," .. i .. "\t") .. "," .. i .. "}"
        else
            return "{" ..              table.concat(tbl, ","             ) ..             "}"
        end
    end

    local function __string(val, n)
        if     type(val) == "table"  then

            if n > 9 then
                return "..."
            end

            local ret = {}

            local t = {}
            for k, _ in pairs(val) do
                t[#t + 1] = k
            end
            table.sort(t)

            for _, k in ipairs(t) do
                if     type(k) == "string" then
                  if k ~= "__index" then
                    ret[#ret+1] = string.format(  "%s=%s",            k , __string(val[k], n+1))
                  end

                elseif type(k) == "number" then
                  if k < 1 or #val < k then
                    ret[#ret+1] = string.format("[%s]=%s",            k , __string(val[k], n+1))
                  else
                    ret[#ret+1] = string.format(     "%s",                __string(val[k], n+1))
                  end

                else
                    ret[#ret+1] = string.format("[%s]=%s", __tostring(k), __string(val[k], n+1))

                end
            end

            return __concat(ret, n)

        elseif type(val) == "string" then
            return string.format("'%s'", val)

        else
            return __tostring(val)

        end
    end

    return __string(t, 1)
end

function debug.localvalues(level)
    local tbl = { string.format("-------- LOCAL VALUES (%s) --------", level) }

    local i = 1

    while true do
        local n, v = debug.getlocal(level+1, i)

        if not n then break end

        tbl[#tbl+1] = string.format("%s = %s", tostring(n), tostring(v))

        i = i + 1
    end

    return table.concat(tbl, "\n")
end

function debug.upvalues(level)
    local tbl = { string.format("-------- UP VALUES (%s) --------", level) }

    local func = debug.getinfo(level+1).func

    local i = 1

    while true do
       local n, v = debug.getupvalue(func, i)

       if not n then break end

       tbl[#tbl+1] = string.format("%s = %s", tostring(n), tostring(v))

       i = i + 1
    end

    return table.concat(tbl, "\n")
end

----------------------------------------
-- 扩展函数 - 调试输出
----------------------------------------

function debug.outputENV()
    debug.output()
    if COCOS2D_DEBUG    then debug.output("COCOS2D_DEBUG"   , COCOS2D_DEBUG    ) end
    if COCOS2D_DEBUG    then debug.output(                                     ) end
    if CC_USE_CURL      then debug.output("CC_USE_CURL"     , CC_USE_CURL      ) end
    if CC_USE_SOCKET    then debug.output("CC_USE_SOCKET"   , CC_USE_SOCKET    ) end
    if CC_USE_WEBSOCKET then debug.output("CC_USE_WEBSOCKET", CC_USE_WEBSOCKET ) end
    if CC_USE_SFS2XAPI  then debug.output("CC_USE_SFS2XAPI" , CC_USE_SFS2XAPI  ) end
    if CC_USE_SQLITE    then debug.output("CC_USE_SQLITE"   , CC_USE_SQLITE    ) end
    if CC_USE_CCSTUDIO  then debug.output("CC_USE_CCSTUDIO" , CC_USE_CCSTUDIO  ) end
    if CC_USE_SPINE     then debug.output("CC_USE_SPINE"    , CC_USE_SPINE     ) end
    if CC_USE_PHYSICS   then debug.output("CC_USE_PHYSICS"  , CC_USE_PHYSICS   ) end
    if CC_USE_TMX       then debug.output("CC_USE_TMX"      , CC_USE_TMX       ) end
    if CC_USE_FILTER    then debug.output("CC_USE_FILTER"   , CC_USE_FILTER    ) end
    if CC_USE_NANOVG    then debug.output("CC_USE_NANOVG"   , CC_USE_NANOVG    ) end
    debug.output()
    debug.output("DEBUG"    , DEBUG    )
    debug.output("DEBUG_LOG", DEBUG_LOG)
    debug.output()
    debug.output("APP_ID"  , APP_ID  )
    debug.output("APP_NAME", APP_NAME)
    debug.output("APP_CODE", APP_CODE)
    debug.output()
    debug.output("DESIGN_SCREEN_WIDTH" , DESIGN_SCREEN_WIDTH )
    debug.output("DESIGN_SCREEN_HEIGHT", DESIGN_SCREEN_HEIGHT)
    debug.output()
    debug.output("PROJ_DOC_PATH", PROJ_DOC_PATH)
    debug.output()
    debug.output("PackagePreloads", debug.getPackagePreloads())
    debug.output()
    debug.output("PackagePaths"   , debug.getPackagePaths()   )
    debug.output()
    debug.output("SearchPaths"    , debug.getSearchPaths()    )
    debug.output()
end

function debug.output(k, v)
    if type(v) == "string" or type(v) == "number" or type(v) == "boolean" then
                print(string.format("# %-20s = %s", k, tostring(v)))
    end
    if type(v) == "nil" then
                print(string.format("# %-20s", k or ""))
    end
    if type(v) == "table" then
        for i, v in ipairs(v) do
            if i == 1 then
                print(string.format("# %-20s = (%s) %s",  k, i, v))
            else
                print(string.format("# %-20s = (%s) %s", "", i, v))
            end
        end
    end
end

function debug.getPackagePreloads()
    local ret = {}
    for k, v in pairs(package.preload) do
        ret[#ret + 1] = k
    end
    table.sort(ret)
    return ret
end

function debug.getPackagePaths()
    local ret, pos = {}, 0
    for st in function() return string.find(package.path, ";", pos) end do
        table.insert(ret, string.sub(package.path, pos, st - 1))
        pos = st + 1
    end
        table.insert(ret, string.sub(package.path, pos))
    return ret
end

function debug.getSearchPaths()
    local ret, src = {}, cc.FileUtils:getInstance():getSearchPaths()
    for i = 0, #src - 2 do
        ret[#ret + 1] = src[#src - i]
    end
    return ret
end

