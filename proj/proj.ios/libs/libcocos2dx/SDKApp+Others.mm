
#import "SDKApp+Base.h"
#import "SDKUtils.h"

@implementation SDKApp (Others)

//
// lua interface - 其他
//

+ (void) mailto:(NSDictionary *)dict
{
    NSString *recipient = [dict objectForKey:@"recipient"];
    NSString *subject   = [dict objectForKey:@"subject"];
    NSString *body      = [dict objectForKey:@"body"];
    
    NSMutableString *url = [NSMutableString string];
    
    [url appendFormat:@"mailto:%@", recipient];
    [url appendFormat:@"?subject=%@", subject];
    [url appendFormat:@"&body=%@",       body];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
}

@end

