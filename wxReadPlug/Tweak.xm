//wxReadPlug hook

#import <UIKIT/UIKIT.h>
#import <Foundation/Foundation.h>
#import <substrate.h>

static dispatch_group_t groupRead = dispatch_group_create();
static dispatch_queue_t queueRead = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);


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


%new
- (void)batchMpDocReadCount {


    NSArray *docRead = [NSArray arrayWithObjects:@"http://mp.weixin.qq.com/s?__biz=MzA4MjEwMTA0Mg==&mid=2650786312&idx=3&sn=90c076f24219c991c3bb48605bc882e0&chksm=8781bc55b0f63543388875607c2572c8935099202b1991264642d34456150c9b754f07a56f8c&mpshare=1&scene=1&srcid=11282YSDHToH5v9AVMGEJKrB#rd",@"http://mp.weixin.qq.com/s?__biz=MzAwMzE0MDA0Mg==&mid=2934218869&idx=1&sn=48ae7bed8bde025ed41d6df1165f24a0&chksm=b02fb0d0875839c6e131b389c0c7eeeaade68de70b3548721cbece8476fecaef2b28d6ccfc9c&mpshare=1&scene=1&srcid=1128v8VcW08oUa3jOQPWNaLC#rd",@"http://mp.weixin.qq.com/s?__biz=MzA4MTI2ODUyMQ==&mid=2651890160&idx=3&sn=e0bc1d551a5a3e5d8c1676d5ce37ae87&chksm=84739bb6b30412a0ff3c947dbf5ed351a0c5b2681f780ce0c4fb3cc188e939d41946fc40359e&mpshare=1&scene=1&srcid=1128u26FMMTxBAX0AYddCNI6#rd",@"http://mp.weixin.qq.com/s?__biz=MzA3NTI0MDE5OA==&mid=2653120171&idx=1&sn=03a039987e594e6333d80840939a8093&chksm=84a440c2b3d3c9d48f0f338c2454aecfc42819a4668ad10a07cab47c4ef74d08c05e9faeacf6&mpshare=1&scene=1&srcid=1128dQl2Nf7QYH1Ac2rleKXe#rd",@"http://mp.weixin.qq.com/s?__biz=MzAwMjgzMDE1Nw==&mid=2650440821&idx=2&sn=03f416cf365a85fab7d25af9d63629dd&chksm=82ca5e57b5bdd741e5ad4d122ab604d5f2b80c84182657b8d7980d0baca4bc274db3f087206f&mpshare=1&scene=1&srcid=1128pt0wGMhwtj5AhekSokxa#rd",nil];


    dispatch_group_async(groupRead, queueRead, ^{

        for (int i = 0; i < [docRead count]; i++) {

            dispatch_async(dispatch_get_main_queue(), ^{

                id web = [[NSClassFromString(@"MMWebViewController") alloc] initWithURL:[NSURL URLWithString:docRead[i]] presentModal:NO extraInfo:nil];

            });

            [NSThread sleepForTimeInterval:1];
        }
    });
    
}


- (void)viewDidAppear:(_Bool)arg1{
    %orig;

    [self createReadButton];
}
%end










