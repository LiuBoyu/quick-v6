
#import <Foundation/Foundation.h>
#import "CCLuaValue.h"

using namespace cocos2d;

@interface SDKIAP : NSObject

//
// lua interface
//

+ (void) init:(NSDictionary *)dict;
+ (void) unload;

+ (void) loadStore;
+ (void) loadProducts:(NSDictionary *)dict;

+ (NSDictionary *) getProduct:(NSDictionary *)dict;

+ (void) purchase:(NSDictionary *)dict;
+ (void) restore;
+ (BOOL) isPurchased:(NSDictionary *)dict;

@end

