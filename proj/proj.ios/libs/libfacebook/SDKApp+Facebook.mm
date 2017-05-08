
#import "SDKApp+Facebook.h"

#import "SDKConfig.h"
#import "SDKUtils.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@implementation SDKApp (Facebook)

//
// lua interface - 会话管理
//

+ (void) startFacebookSDK:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
}

+ (void) applicationDidBecomeActiveByFacebookSDK
{
    [FBSDKAppEvents activateApp];
}

+ (BOOL) applicationByFacebookSDK:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

+ (BOOL) applicationByFacebookSDK:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options
{
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                          options:options];
}

//
// lua interface - 会话管理
//

+ (void) logInByFacebookSDK:(NSDictionary *)dict
{
    int callback = [[dict objectForKey:@"callback"] intValue];
    
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login logInWithReadPermissions: @[@"public_profile", @"email", @"user_friends"]
                 fromViewController: [SDKUtils getViewController]
                            handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                                LuaBridge::pushLuaFunctionById(callback);
                                
                                if (error) {
                                    LuaBridge::getStack()->pushString(@"Error".UTF8String);
                                } else if (result.isCancelled) {
                                    LuaBridge::getStack()->pushString(@"Cancel".UTF8String);
                                } else {
                                    LuaBridge::getStack()->pushString(@"Success".UTF8String);
                                }
                                
                                LuaBridge::getStack()->executeFunction(1);
                                LuaBridge::releaseLuaFunctionById(callback);
                            }];
}

+ (void) logOutByFacebookSDK
{
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login logOut];
}

+ (NSString *) getCurrentAccessTokenByFacebookSDK
{
    FBSDKAccessToken *token = [FBSDKAccessToken currentAccessToken];
    
    if (token) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        
        [dict setObject:token.tokenString         forKey:@"token"];
        [dict setObject:token.appID               forKey:@"applicationId"];
        [dict setObject:token.userID              forKey:@"userId"];
        
        NSMutableArray *permissions         = [[NSMutableArray alloc] init];
        NSMutableArray *declinedPermissions = [[NSMutableArray alloc] init];
        
        NSEnumerator *enumerator1 = [token.permissions         objectEnumerator];
        NSEnumerator *enumerator2 = [token.declinedPermissions objectEnumerator];
        
        for (NSString *obj in enumerator1) {
            [permissions         addObject:obj];
        }
        for (NSString *obj in enumerator2) {
            [declinedPermissions addObject:obj];
        }
        
        [dict setObject:permissions         forKey:@"permissions"];
        [dict setObject:declinedPermissions forKey:@"declinedPermissions"];
        
        BOOL isExpired = [token.expirationDate timeIntervalSinceNow] < 0;
        
        [dict setObject:[NSNumber numberWithBool:isExpired] forKey:@"isExpired"];
        
        NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
        NSString *ret = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        return ret;
    } else {
        return nil;
    }
}

//
// lua interface - Graph API
//

+ (void) GETByFacebookSDK:(NSDictionary *)dict
{
    NSString     *graphPath   =  [dict objectForKey:@"graphPath" ];
    NSDictionary *parameters  = [SDKUtils toNSDictionary:(NSString *)[dict objectForKey:@"parameters"]];
    int           callback    = [[dict objectForKey:@"callback"  ] intValue];
    
    [[[FBSDKGraphRequest alloc] initWithGraphPath:graphPath parameters:parameters] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        LuaBridge::pushLuaFunctionById(callback);
        
        if (!error)
        {
            LuaBridge::getStack()->pushNil();
            LuaBridge::getStack()->pushLuaValue([SDKUtils serializeNSDictionary:result]);
        }
        else
        {
            LuaBridge::getStack()->pushLuaValue([SDKUtils serializeNSError:error]);
            LuaBridge::getStack()->pushNil();
        }
        
        LuaBridge::getStack()->executeFunction(2);
        LuaBridge::releaseLuaFunctionById(callback);
    }];
}

@end

