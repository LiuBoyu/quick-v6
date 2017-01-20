
local M = class("UnitTest", function()
    return display.newScene()
end)

function M:ctor()
    UI:DebugScene(self)

    self:MENU("Facebook")

    self:TEST("logIn", function()
        G.App:logInByFacebookSDK(function()
            print("logIn")
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

    self:TEST("Me", function()
        G.App:GETbyFacebookSDK({
            graphPath  = "/me",
            parameters = {
                fields = "id,name,first_name,last_name,email,picture.height(160).width(160)",
            },
            callback   = function(res)
                print(tostring(res))
                 G.Me:set("fb_name",res.name)
                            G.Me:set("fb_id",res.id)
                            G.Me:set("fb_picture_heigh",res.picture.data.height)
                            G.Me:set("fb_picture_weight",res.picture.data.weight)
                            G.Me:set("fb_is_silhouette",res.picture.data.is_silhouette)
                            G.Me:set("fb_picture_weight",res.picture.data.url)
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

