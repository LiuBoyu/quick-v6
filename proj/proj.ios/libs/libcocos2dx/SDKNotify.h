
#import <Foundation/Foundation.h>
#import "CCLuaValue.h"

using namespace cocos2d;

@interface SDKNotify : NSObject

//
// lua interface
//

+ (void) scheduleLocalNotify:(NSDictionary *)dict;
+ (void) cancelLocalNotifies;

//
// lua interface
//

+ (int)  getAppIconBadgeNumber;
+ (void) setAppIconBadgeNumber:(NSDictionary *)dict;

@end
