
#import "SDKNotify.h"
#import "CCLuaBridge.h"

@implementation SDKNotify

//
// lua interface
//

+ (void) scheduleLocalNotify:(NSDictionary *)dict
{
    id contentTitle          = [dict objectForKey:@"contentTitle"];
    id contentText           = [dict objectForKey:@"contentText"];
    id timeIntervalSinceNow  = [dict objectForKey:@"timeIntervalSinceNow"];
    id timeIntervalSince1970 = [dict objectForKey:@"timeIntervalSince1970"];
    id repeatInterval        = [dict objectForKey:@"repeatInterval"];
    
    // 创建通知
    UILocalNotification *notify = [[[UILocalNotification alloc] init] autorelease];
    // 通知时区
    notify.timeZone = [NSTimeZone defaultTimeZone];
    // 通知声音
    notify.soundName = UILocalNotificationDefaultSoundName;
    
    // 通知时间
    notify.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
    if (timeIntervalSinceNow)
    {
        notify.fireDate = [NSDate dateWithTimeIntervalSinceNow:[timeIntervalSinceNow intValue]];
    }
    if (timeIntervalSince1970)
    {
        notify.fireDate = [NSDate dateWithTimeIntervalSinceNow:[timeIntervalSince1970 intValue]];
    }
    // 重复通知
    if (repeatInterval)
    {
        notify.repeatInterval = [repeatInterval intValue];
    }
    
    // 通知动作
    if (contentTitle)
    {
        notify.alertAction = contentTitle;
    }
    // 通知内容
    if (contentText)
    {
        notify.alertBody = contentText;
    }
    
    // 通知角标
    notify.applicationIconBadgeNumber = 1;
    // 注册通知
    [[UIApplication sharedApplication] scheduleLocalNotification:notify];
}

+ (void) cancelLocalNotifies
{
    // 重置通知角标
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    // 取消所有通知
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

//
// lua interface
//

+ (int)  getAppIconBadgeNumber
{
    return [UIApplication sharedApplication].applicationIconBadgeNumber;
}

+ (void) setAppIconBadgeNumber:(NSDictionary *)dict
{
    int appIconBadgeNumber = [[dict objectForKey:@"appIconBadgeNumber"] intValue];
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = appIconBadgeNumber;
}

@end
