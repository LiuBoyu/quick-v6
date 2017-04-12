
#import "SDKUtils.h"
#import "CCLuaBridge.h"

@implementation SDKUtils

// tools

static UIViewController *sharedViewController;

+ (UIViewController *) getViewController
{
    return sharedViewController;
}

+ (void) setViewController:(UIViewController *) viewController
{
    sharedViewController = viewController;
}

// tools

+ (NSString *) getParamS:(NSDictionary *)dict key:(NSString *)key
{
    return [dict objectForKey:key];
}

+ (BOOL) getParamB:(NSDictionary *)dict key:(NSString *)key
{
    return [[dict objectForKey:key] boolValue];
}

+ (int) getParamI:(NSDictionary *)dict key:(NSString *)key
{
    return [[dict objectForKey:key] intValue];
}

+ (int) getParamF:(NSDictionary *)dict key:(NSString *)key
{
    if ([dict objectForKey:key])
    {
        return [[dict objectForKey:key] intValue];
    }
    return 0;
}

//
// tools
//

+ (NSArray *) toNSArray:(NSString *)json
{
    if (json == nil) return nil;
    
    NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err = nil;
    
    id jsonObj = [NSJSONSerialization JSONObjectWithData:data
                                                 options:NSJSONReadingAllowFragments
                                                   error:&err];
    
    if ([jsonObj isKindOfClass:[NSArray class]])
    {
        return (NSArray *)jsonObj;
    }
    
    return nil;
}

+ (NSDictionary *) toNSDictionary:(NSString *)json
{
    if (json == nil) return nil;
    
    NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err = nil;
    
    id jsonObj = [NSJSONSerialization JSONObjectWithData:data
                                                 options:NSJSONReadingAllowFragments
                                                   error:&err];
    
    if ([jsonObj isKindOfClass:[NSDictionary class]])
    {
        return (NSDictionary *)jsonObj;
    }
    
    return nil;
}

//
// tools
//

+ (LuaValue) serializeNSError:(NSError *)error
{
    LuaValueDict ret;
    
    ret["code"] = LuaValue::intValue((int)[error code]);
    ret["text"] = LuaValue::stringValue([[error localizedDescription] UTF8String]);
    
    return LuaValue::dictValue(ret);
}

+ (LuaValue) serializeNSNumber:(NSNumber *)val
{
    const char * pObjCType = [val objCType];
    
    if (strcmp(pObjCType, @encode(BOOL)) == 0)
    {
        return LuaValue::booleanValue([val boolValue]);
    }
    if (strcmp(pObjCType, @encode(int))  == 0)
    {
        return LuaValue::intValue([val intValue]);
    }
    if (strcmp(pObjCType, @encode(float)) == 0)
    {
        return LuaValue::floatValue([val floatValue]);
    }
    
    return LuaValue::floatValue([val floatValue]);
}

+ (LuaValue) serializeNSString:(NSString *)val
{
    return LuaValue::stringValue([val UTF8String]);
}

+ (LuaValue) serializeNSDictionary:(NSDictionary *)dict
{
    LuaValueDict ret;
    
    for (NSString *key in dict)
    {
        id val = [dict objectForKey:key];
        
        if ([val isKindOfClass:[NSNumber     class]])
        {
            ret[[key UTF8String]] = [SDKUtils serializeNSNumber    :(NSNumber     *)val];
        }
        if ([val isKindOfClass:[NSString     class]])
        {
            ret[[key UTF8String]] = [SDKUtils serializeNSString    :(NSString     *)val];
        }
        if ([val isKindOfClass:[NSArray      class]])
        {
            ret[[key UTF8String]] = [SDKUtils serializeNSArray     :(NSArray      *)val];
        }
        if ([val isKindOfClass:[NSDictionary class]])
        {
            ret[[key UTF8String]] = [SDKUtils serializeNSDictionary:(NSDictionary *)val];
        }
    }
    
    return LuaValue::dictValue(ret);
}

+ (LuaValue) serializeNSArray:(NSArray *)array
{
    LuaValueArray ret;
    
    for(NSObject *val in array)
    {
        if ([val isKindOfClass:[NSNumber     class]])
        {
            ret.push_back([SDKUtils serializeNSNumber    :(NSNumber     *)val]);
        }
        if ([val isKindOfClass:[NSString     class]])
        {
            ret.push_back([SDKUtils serializeNSString    :(NSString     *)val]);
        }
        if ([val isKindOfClass:[NSArray      class]])
        {
            ret.push_back([SDKUtils serializeNSArray     :(NSArray      *)val]);
        }
        if ([val isKindOfClass:[NSDictionary class]])
        {
            ret.push_back([SDKUtils serializeNSDictionary:(NSDictionary *)val]);
        }
    }
    
    return LuaValue::arrayValue(ret);
}

@end

