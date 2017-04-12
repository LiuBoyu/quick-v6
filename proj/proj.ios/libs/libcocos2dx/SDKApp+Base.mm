
#import "SDKApp+Base.h"
#import "SDKUtils.h"
#import "sys/utsname.h"

@implementation SDKApp (Base)

//
// lua interface - 设备信息
//

+ (NSDictionary *) getDeviceInfo
{
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    NSMutableDictionary *os   = [NSMutableDictionary dictionary];
    
    [info setObject:[SDKApp getDeviceModel] forKey:@"model"];
    [info setObject:os                      forKey:@"os"   ];
    
    [os setObject:[SDKApp getDeviceOSName]    forKey:@"name"    ];
    [os setObject:[SDKApp getDeviceOSVersion] forKey:@"version" ];
    [os setObject:[SDKApp getDeviceCountry]   forKey:@"country" ];
    [os setObject:[SDKApp getDeviceLanguage]  forKey:@"language"];
    
    return info;
}

+ (NSString *) getDeviceOSName
{
    return @"iOS";
}

+ (NSString *) getDeviceOSVersion
{
    return [UIDevice currentDevice].systemVersion;
}

+ (NSString *) getDeviceModel
{
    struct utsname systemInfo;
    
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

+ (NSString *) getDeviceCountry
{
    return [[NSLocale currentLocale] localeIdentifier];
}

+ (NSString *) getDeviceLanguage
{
    return [[NSLocale preferredLanguages] objectAtIndex:0];
}

//
// lua interface - 应用信息
//

+ (NSDictionary *) getAppInfo
{
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    
    [info setObject:[SDKApp getAppId     ] forKey:@"id"     ];
    [info setObject:[SDKApp getAppName   ] forKey:@"name"   ];
    [info setObject:[SDKApp getAppVersion] forKey:@"version"];
    
    return info;
}

+ (NSString *) getAppId
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleIdentifierKey];
}

+ (NSString *) getAppName
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleNameKey];
}

+ (NSString *) getAppVersion
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
}

@end

