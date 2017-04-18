
#import <Foundation/Foundation.h>
#import "SDKApp.h"

@interface SDKApp (Facebook)

//
// lua interface - 会话管理
//

+ (void) startFacebookSDK:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
+ (void) applicationDidBecomeActiveByFacebookSDK;

+ (BOOL) applicationByFacebookSDK:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;
+ (BOOL) applicationByFacebookSDK:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options;

+ (void) logInByFacebookSDK:(NSDictionary *)dict;
+ (void) logOutByFacebookSDK;

+ (NSString *) getCurrentAccessTokenByFacebookSDK;

+ (void) GETByFacebookSDK:(NSDictionary *)dict;

@end

