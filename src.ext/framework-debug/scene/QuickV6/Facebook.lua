
local M = class("UnitTest", function()
    return display.newScene()
end)

function M:ctor()
    UI:DebugScene(self)

    self:MENU("Facebook")

    self:TEST("logIn", function()
        G.App:logInByFacebookSDK(function(ret)
            print("logIn", ret)
        end)
    end)

    self:TEST("logOut", function()
        G.App:logOutByFacebookSDK()
        print("logOut")
    end)

    self:TEST("getToken", function()
        local token = G.App:getCurrentAccessTokenByFacebookSDK()
        print(tostring(token))
    end)

    self:TEST("onAccessTokenChanged", function()
        G.App:setOnCurrentAccessTokenChangedByFacebookSDK(function(old, current)
            print("onCurrentAccessTokenChanged")
            print(tostring(old    ))
            print(tostring(current))
        end)
    end)

    self:TEST("request", function()
        G.App:requestByFacebookSDK({
            recipients = {},
            message    = "Hello",
            title      = "World",
            callback   = function(res)
                print(tostring(res))
            end,
        })
    end)

    self:TEST("Me", function(sb)
        local a = display.newSprite()
            :align(display.CENTER, display.cx, display.cy)
            :addTo(sb)

        Component(a)
            :addComponent("EventProxy")
            :addComponent("UI.UrlPic")

        a:listenModelByInit(G.Me, "fb_picture_url", function(e)
            a:setUrl(e.v)
        end)

        G.App:GETbyFacebookSDK({
            graphPath  = "/me",
            parameters = {
                fields = "id,name,first_name,last_name,email,picture.height(160).width(160)",
            },
            callback   = function(res)
                G.Me:set("fb_name",res.name)
                G.Me:set("fb_id",res.id)
                G.Me:set("fb_picture_height",res.picture.data.height)
                G.Me:set("fb_picture_width",res.picture.data.width)
                G.Me:set("fb_is_silhouette",res.picture.data.is_silhouette)
                G.Me:set("fb_picture_url",res.picture.data.url)
            end,
        })
    end)

    self:TEST("Friends", function()
        G.App:GETbyFacebookSDK({
            graphPath  = "/me/friends",
            parameters = {
                fields = "id,name,first_name,last_name,email,picture.height(160).width(160)",
            },
            callback   = function(res)
                print(tostring(res))
            end,
        })
    end)

    self:TEST("Invitable", function()
        G.App:GETbyFacebookSDK({
            graphPath  = "/me/invitable_friends",
            parameters = {
                fields = "id,name,first_name,last_name,email,picture.height(160).width(160)",
            },
            callback   = function(res)
                print(tostring(res))
                print(#res.data)
            end,
        })
    end)

end

return M

