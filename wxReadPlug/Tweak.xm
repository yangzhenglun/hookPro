//wxReadPlug hook

#import <UIKIT/UIKIT.h>
#import <Foundation/Foundation.h>
#import <substrate.h>

static dispatch_group_t groupRead = dispatch_group_create();
static dispatch_queue_t queueRead = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

extern "C" NSString * readFileData(NSString * fileName) {
    NSLog(@"HKWeChat readFileData:%@",fileName);
    //    @autoreleasepool {
    NSLog(@"HKWeChat file exists: %@", [[NSFileManager defaultManager] fileExistsAtPath:fileName] ? @"YES": @"NO");
    if([[NSFileManager defaultManager] fileExistsAtPath:fileName]){
        NSString *strData = [NSString stringWithContentsOfFile:fileName encoding:NSUTF8StringEncoding error:NULL];

        return strData;
    }else{
        return @"";
    }
}


@interface NewMainFrameViewController{
}

- (void)viewDidAppear:(_Bool)arg1;
- (void)createReadButton;

@end

%hook NewMainFrameViewController


%new
- (void)createReadButton{
    UIButton *addAndSendBtn = [[UIButton alloc] initWithFrame:CGRectMake(100, 25, 150, 30)];
    [addAndSendBtn setTitle:@"刷阅读" forState:UIControlStateNormal];
    [addAndSendBtn setTitleColor:[UIColor redColor]forState:UIControlStateNormal];
    [addAndSendBtn setBackgroundColor:[UIColor whiteColor]];
    [addAndSendBtn addTarget: self action:@selector(batchMpDocReadCount)
            forControlEvents: UIControlEventTouchDown];
    [[[[[[UIApplication sharedApplication]delegate] window] rootViewController] view] addSubview:addAndSendBtn];
}

id webMapDoc = nil;
%new
- (void)batchMpDocReadCount {

    NSLog(@"11111111111111");
    NSString *readData = readFileData(@"/var/root/redDoc.txt");
    NSLog(@"%@",readData);

    NSArray *docRead = [readData componentsSeparatedByString:@","]; //从字符A中分隔成2个元素的数组;

    dispatch_group_async(groupRead, queueRead, ^{

        for (int i = 0; i < [docRead count]; i++) {

            dispatch_async(dispatch_get_main_queue(), ^{

                if(!webMapDoc){
                    id webMapDoc = [[NSClassFromString(@"MMWebViewController") alloc] initWithURL:[NSURL URLWithString:docRead[i]] presentModal:NO extraInfo:nil];

                    //跳转到页面
                    NSLog(@"docRead[i]:%@",docRead[i]);

                    [[self navigationController] pushViewController:webMapDoc animated: YES];

                }else{
                    [webMapDoc goToURL:[NSURL URLWithString:docRead[i]]];
                    
                    NSLog(@"goToURL docRead[i]:%@",docRead[i]);
                }

            });

            [NSThread sleepForTimeInterval:5];
        }


    });
    
}


- (void)viewDidAppear:(_Bool)arg1{
    %orig;

    [self createReadButton];
}
%end










