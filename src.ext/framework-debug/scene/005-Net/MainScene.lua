
local M = class("UnitTest", function()
    return display.newScene()
end)

function M:ctor(args)
    UI:DebugScene(self, args)

    local sfclient = G.SFClient

    self:addComponent("SFProxy")
        :addComponent("UI.Busy")

    -- sfclient:setOnConnect(function(msg)
    --     log.info("OnConnect - %s", msg)
    -- end)

    -- sfclient:setOnMessage(function(cmd, msg)
    --     log.info("OnMessage - %s %s", cmd, msg)
    -- end)

    -- sfclient:setOnClose(function(msg)
    --     log.info("OnClose - %s", msg)
    -- end)

    self:MENU("SFClient")

    self:TEST("connect", function()
        sfclient:connect(function(msg)
        end)
    end)

    self:TEST("close", function()
        sfclient:close()
    end)

    self:TEST("kill", function()
        sfclient:kill()
    end)

    self:TEST("login", function()
        sfclient:request("@login", {
            payload = {
                userName = G.App:getUdid(),
                password = string.sub(G.App:getUdid(), -6),
                params   = {
                    ua        = "123456",
                    imei      = G.App:getUdid(),
                    imsi      = "123456",
                    iccid     = "123456",
                    version   = "123456",
                    channelid = "123456",
                },
            },
            onComplete = function(e)
            end,
        })
    end)

    self:TEST("logout", function()
        sfclient:request("@logout", {
            onComplete = function(e)
            end,
        })
    end)

    self:TEST("enableLagMonitor", function()
        sfclient:enableLagMonitor(true)
    end)

    self:TEST("cancelAll", function()
        sfclient:cancelAll()
    end)

    self:MENU("CMD")

    local i = 0

    self:TEST("add", function()
        for j = 1, 10 do
            i = i + 1
            local id = sfclient:request("add", {
                payload = {
                    n1 = i,
                    n2 = 0,
                },
                onComplete = function(e)
                end,
            })
            if id % 5 == 0 then
                sfclient:cancel(id)
            end
        end
    end)

    local l

    self:TEST("add(++)", function()
        l = scheduler.scheduleGlobal(function()
            for j = 1, 10 do
                i = i + 1
                sfclient:request("add", {
                    payload = {
                        n1 = i,
                        n2 = 0,
                    },
                    onComplete = function(e)
                    end,
                })
            end
        end, 0.1)
    end)

    self:TEST("add(--)", function()
        if l then
            scheduler.unscheduleGlobal(l)
            l = nil
        end
    end)

    self:TEST("add(闪断)", function()
        sfclient:request("add", {
            payload = {
                n1 = 1,
                n2 = 0,
            },
            onComplete = function(e)
                print(1, tostring(e))
            end,
        })
        sfclient:request("add", {
            payload = {
                n1 = 2,
                n2 = 0,
            },
            onComplete = function(e)
                print(2, tostring(e))
            end,
        })
        sfclient:kill()
        sfclient:request("add", {
            payload = {
                n1 = 3,
                n2 = 0,
            },
            onComplete = function(e)
                print(3, tostring(e))
            end,
        })
        sfclient:request("add", {
            payload = {
                n1 = 4,
                n2 = 0,
            },
            onComplete = function(e)
                print(4, tostring(e))
            end,
        })
    end)

    self:TEST("echo", function()
        sfclient:request("echo", {
            payload = {
                text = "Hello World!",
            },
            onComplete = function(e)
            end,
        })
    end)

    self:MENU("Component", { newline = false })

    self:TEST("add", function()
        self:REQUEST("add", {
            payload = {
                n1 = 9,
                n2 = 0,
            },
            onComplete = function(e)
            end,
        })
        self:REQUEST("add", {
            payload = {
                n1 = 9,
                n2 = 0,
            },
            onComplete = function(e)
            end,
        })
    end)

    self:MENU("OUTPUT")

    self:TEST("sfclient.status", function()
        log.info("sfclient.status = %s", sfclient.status)
    end)

    self:TEST("sfclient.req", function()
        log.info("sfclient.req = %s", sfclient.req)
    end)

    self:TEST("sfclient.queue", function()
        log.info("sfclient.queue = %s", sfclient.queue)
    end)

    self:MENU("Room")

    self:TEST("JoinRoom", function()
        self:JoinRoomPOST({ gid = 200 }, function(e, data)
        end)
    end)

    self:TEST("INITDEAL", function()
        self:PUBLISH("INITDEAL")
        self:RECEIVE("INITDEALT", {
            callback = function(e, data)
            end,
            source = G.Net,
        })
    end)

    self:TEST("STARTGAME", function()
        self:PUBLISH("STARTGAME")
        self:RECEIVE("GAMESTARTED", {
            callback = function(e, data)
            end,
            source = G.Net,
        })
    end)

    self:TEST("ExitRoom", function()
    end)

end

return M

