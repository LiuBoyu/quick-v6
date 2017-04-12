
#import <Foundation/Foundation.h>
#import "CCLuaValue.h"

using namespace cocos2d;

@interface SDKApp : NSObject

//
// objc interface - 应用回调
//

+ (void) applicationDidFinishLaunching;
+ (void) applicationWillEnterForeground;
+ (void) applicationDidBecomeActive;
+ (void) applicationWillResignActive;
+ (void) applicationDidEnterBackground;
+ (void) applicationWillTerminate;
+ (void) applicationDidReceiveMemoryWarning;
+ (BOOL) handleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication;

@end

