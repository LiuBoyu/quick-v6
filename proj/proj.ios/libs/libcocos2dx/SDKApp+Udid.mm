
#import "SDKApp+Base.h"
#import "SDKUtils.h"

#import "KeychainItemWrapper.h"

@implementation SDKApp (Udid)

//
// lua interface - UDID && UUID
//

+ (NSString *) getUdid
{
    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"UUID" accessGroup:nil];
    
    NSString *UUID = [keychainItem objectForKey:(id)kSecValueData];
    
    if ([UUID isEqualToString:@""])
    {
        UUID = (NSString *) CFUUIDCreateString(kCFAllocatorDefault, CFUUIDCreate(kCFAllocatorDefault));
        
        [keychainItem setObject:UUID forKey:(id)kSecValueData];
    }
    
    return UUID;
}

+ (NSString *) getUuid
{
    return (NSString *) CFUUIDCreateString(kCFAllocatorDefault, CFUUIDCreate(kCFAllocatorDefault));
}

@end

