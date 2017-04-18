
#import "SDKApp.h"
#import "CCLuaBridge.h"

@implementation SDKApp

//
// objc interface - 应用回调
//

+ (void) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
}

+ (void) applicationWillEnterForeground
{
}

+ (void) applicationDidBecomeActive
{
}

+ (void) applicationWillResignActive
{
}

+ (void) applicationDidEnterBackground
{
}

+ (void) applicationWillTerminate
{
}

+ (void) applicationDidReceiveMemoryWarning
{
}

+ (BOOL) application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return YES;
}

+ (BOOL) application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options
{
    return YES;
}

@end

