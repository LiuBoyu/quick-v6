
#import <Foundation/Foundation.h>
#import "SDKApp.h"

@interface SDKApp (Base)

//
// lua interface - 设备信息
//

+ (NSDictionary *) getDeviceInfo;

+ (NSString *) getDeviceOSName;
+ (NSString *) getDeviceOSVersion;
+ (NSString *) getDeviceModel;
+ (NSString *) getDeviceCountry;
+ (NSString *) getDeviceLanguage;

//
// lua interface - 应用信息
//

+ (NSDictionary *) getAppInfo;

+ (NSString *) getAppId;
+ (NSString *) getAppName;
+ (NSString *) getAppVersion;

@end

