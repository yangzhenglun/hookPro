//systemVersion hook

#import <UIKIT/UIKIT.h>
#import <Foundation/Foundation.h>
#import <substrate.h>

%hook UIDevice
+ (int)getSysInfo:(unsigned int)arg1 {
    int res = %orig;
    NSLog(@"MYHOOK getSysInfo: %d %d", arg1, res);
    return res;
}

+ (id)getSysInfoByName:(char *)arg1 {
    id res = %orig;
    NSLog(@"MYHOOK getSysInfoByName: %s, %@", arg1, res);
    return res;
}

- (id)platform {
    id res = %orig;
    NSLog(@"MYHOOK platform: %@", res);
    return res;
}
- (id)systemVersion {
    id res = %orig;
    NSLog(@"MYHOOK currSysversion: %@", res);
    return @"8.1";
}

%end