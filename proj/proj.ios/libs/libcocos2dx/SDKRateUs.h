
#import <Foundation/Foundation.h>
#import "CCLuaValue.h"

#import "iRate.h"

using namespace cocos2d;

@interface SDKRateUs : NSObject <iRateDelegate>

//
// lua interface
//

+ (void) load:(NSDictionary *)dict;

+ (BOOL) shouldRateUs;
+ (void)   showRateUs;
+ (void)   openRateUsPage;

+ (void) rateus;
+ (void) remind;
+ (void) decline;

+ (BOOL) isRatedUs;
+ (BOOL) isDeclined;

+ (void) reset;

//
// iRateDelegate
//

- (void) iRateDidPromptForRating;
- (void) iRateDidOpenAppStore;
- (void) iRateUserDidAttemptToRateApp;
- (void) iRateUserDidRequestReminderToRateApp;
- (void) iRateUserDidDeclineToRateApp;

@end
