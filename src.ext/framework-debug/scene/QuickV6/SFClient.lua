
local M = class("UnitTest", function()
    return display.newScene()
end)

function M:ctor()
    UI:DebugScene(self)
        :addComponent("SFProxy")
        :addComponent("UI.Busy")

    local sfclient = G.SFClient

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

    self:MENU("SFClient", { newline = false })

    self:TEST("sfclient.status", function()
        log.info("sfclient.status = %s", sfclient.status)
    end)

    self:TEST("sfclient.req", function()
        log.info("sfclient.req = %s", sfclient.req)
    end)

    self:TEST("sfclient.queue", function()
        log.info("sfclient.queue = %s", sfclient.queue)
    end)

    self:MENU("Cmd", { newline = false })

    self:TEST("echo", function()
        sfclient:request("echo", {
            payload = {
                text = "Hello World!",
            },
            onComplete = function(e)
            end,
        })
    end)

end

return M

