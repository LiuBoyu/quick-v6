
#import "SDK3rd.h"
#import "SDKUtils.h"
#import "CCLuaBridge.h"

// Cocos2dSDK
#import "SimpleAudioEngine.h"
#import "cocos2d.h"

@implementation SDK3rd

static SDK3rd *s_sharedInstance = NULL;

+ (SDK3rd *) sharedInstance
{
    if (!s_sharedInstance)
    {
        s_sharedInstance = [[SDK3rd alloc] init];
    }
    return s_sharedInstance;
}

//
// objc interface - 应用回调
//

+ (void) applicationDidFinishLaunching
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

+ (BOOL) handleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication
{
    return YES;
}

@end

