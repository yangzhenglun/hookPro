//微信注册的hook

#import <UIKIT/UIKIT.h>
#import <Foundation/Foundation.h>
#import <substrate.h>
static dispatch_group_t group = dispatch_group_create();
static dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);


//微信注册HOOK

//写文件
extern "C" BOOL write2File(NSString *fileName, NSString *content) {
    [content writeToFile:fileName atomically:NO encoding:NSUTF8StringEncoding error:nil];
    return YES;
}

@interface PSListController

@property(retain, nonatomic) UITableView *table;
@end

@interface PrefsListController : PSListController
- (void)tableView:(id)arg1 didSelectRowAtIndexPath:(id)arg2;  //[NSIndexPath indexPathForRow:0 inSection:2]
- (void)viewDidAppear:(_Bool)arg1;
@end


@interface GeneralController : PSListController
- (void)viewDidAppear:(_Bool)arg1;
- (void)tableView:(id)arg1 didSelectRowAtIndexPath:(id)arg2;
@end

@interface VPNNEController
@property(retain, nonatomic) UITableView *table;
- (void)viewDidAppear:(_Bool)arg1;
- (void)viewDidLoad;
- (void)tableView:(id)arg1 didSelectRowAtIndexPath:(id)arg2;
- (id)init;
@end


%hook PrefsListController
- (void)viewDidAppear:(_Bool)arg1{
    %orig;

    NSLog(@"MYHOOK is Preferences");
    dispatch_group_async(group, queue, ^{

        [NSThread sleepForTimeInterval:1];

        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"MYHOOK is Preferences 进入通用");

            [self tableView:[self table] didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];
        });
        
    });

}
%end

%hook GeneralController
- (void)viewDidAppear:(_Bool)arg1{
    %orig;

    NSLog(@"MYHOOK is 在通用页面里");


    dispatch_group_async(group, queue, ^{

        [NSThread sleepForTimeInterval:1];

        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"MYHOOK is Preferences 进入VPN 页面");

            [self tableView:[self table] didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:6]];
        });
        
    });
}
%end














