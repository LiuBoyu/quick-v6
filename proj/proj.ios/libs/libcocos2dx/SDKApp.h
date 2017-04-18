
#import <Foundation/Foundation.h>
#import "CCLuaValue.h"

using namespace cocos2d;

@interface SDKApp : NSObject

//
// objc interface - 应用回调
//

+ (void) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;

+ (void) applicationWillEnterForeground;
+ (void) applicationDidBecomeActive;
+ (void) applicationWillResignActive;
+ (void) applicationDidEnterBackground;
+ (void) applicationWillTerminate;
+ (void) applicationDidReceiveMemoryWarning;

+ (BOOL) application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;
+ (BOOL) application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options;

@end

