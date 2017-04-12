
#import <Foundation/Foundation.h>
#import "SDKApp.h"

@interface SDKApp (Udid)

//
// lua interface - UDID && UUID
//

+ (NSString *) getUdid;
+ (NSString *) getUuid;

@end

