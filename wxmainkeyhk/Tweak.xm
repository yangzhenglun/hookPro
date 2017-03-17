//wxmainkeyhk hook

#import <UIKIT/UIKIT.h>
#import <Foundation/Foundation.h>
#import <substrate.h>

@interface CUtility
+ (id)GetUUIDNew;
@end


%hook CUtility

+ (id)GetUUIDNew {
    NSString *myUUID = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/Documents/myuuid.dat", NSHomeDirectory()]];

    if (!myUUID || [myUUID isEqualToString:@""]) {

        NSLog(@"wxmainkeyhk is read myuuid.bat is %@ %@",myUUID,%orig);
        if (!myUUID || [myUUID isEqualToString:@""]) {
            exit(0);
        }
    }

    return myUUID;
}
%end