
#import "wxSendVoice.h"
#pragma GCC diagnostic ignored "-Wgnu"
#pragma GCC diagnostic ignored "-Wundef"
#pragma GCC diagnostic ignored "-Wselector"

static BOOL m_isChatRoom = NO;
static int m_clickButton = -1;

static CSetting *m_nCSetting = [[NSClassFromString(@"CSetting") alloc] init];  //下面的table页

%hook BaseMsgContentViewController
%property(nonatomic, retain)UIButton *btn;

- (void)viewDidDisappear:(BOOL)arg1 {
    %orig;
    if ([self btn]) {
        [[self btn] removeFromSuperview];
    }
}


- (void)viewDidAppear:(BOOL)arg1 {
    %orig;

    if (![[[self m_delegate] m_contact] isChatroom]) {
        m_isChatRoom = NO;
    }else{
        m_isChatRoom = YES;
    }

    if ([self btn]) {
        [[self btn] removeFromSuperview];
    }

    [self setBtn:[UIButton buttonWithType:UIButtonTypeCustom]];

    if (m_isChatRoom) {
        [[self btn] setTitle:@"群" forState:UIControlStateNormal];
        [[self btn] setBackgroundColor:[UIColor redColor]];
    } else {
        [[self btn] setTitle:@"个人" forState:UIControlStateNormal];
        [[self btn] setBackgroundColor:[UIColor redColor]];
    }

    [[self btn] setFrame:CGRectMake(50, 80, 50, 50)];
    [[[self btn] layer] setMasksToBounds:YES];
    [[[self btn] layer] setCornerRadius:25];

    [[self btn] addTarget:self action:@selector(MonitorButtonClicked) forControlEvents:UIControlEventTouchUpInside];

    [[self view] addSubview:[self btn]];
}

- (void)viewDidLayoutSubviews {
    %orig;
}

- (void)viewDidLoad {
    %orig;
}


dispatch_queue_t voicequeue = dispatch_queue_create("sendVoiceMessage", DISPATCH_QUEUE_CONCURRENT);
//发送语音
%new
-(void)sendVoiceMessage:(NSString *)toUser voiceUrl:(NSString *)voiceUrl voiceTime:(NSString*)voiceTime{
    NSLog(@"发送语音消息");
    //wxid_x4asq8c7bov521  http://crobo-pic.qiniudn.com/test2.amr

    if([voiceUrl isEqualToString:@""]){
        NSLog(@"发送语音消息为空,不能发送语音消息");
        return;
    }

    dispatch_barrier_async(voicequeue, ^{
        int msgType = 34;
        CMessageWrap *voiceMsg = [[NSClassFromString(@"CMessageWrap") alloc] initWithMsgType:msgType nsFromUsr:[m_nCSetting m_nsUsrName]];
        CMessageMgr *msMgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CMessageMgr")];

        voiceMsg = [[NSClassFromString(@"CMessageWrap") alloc] initWithMsgType:msgType nsFromUsr:[m_nCSetting m_nsUsrName]];
        voiceMsg.m_uiVoiceFormat = 4;
        voiceMsg.m_nsFromUsr = [m_nCSetting m_nsUsrName];
        voiceMsg.m_nsToUsr = toUser;
        voiceMsg.m_uiVoiceEndFlag = 1;
        voiceMsg.m_uiCreateTime = (int)time(NULL);

        NSData *voiceData = [NSData dataWithContentsOfURL:[NSURL URLWithString:voiceUrl]];
        NSLog(@"========2============");
        NSString *path = [NSClassFromString(@"CMessageWrap") getPathOfMsgImg:voiceMsg];
        path = [path stringByReplacingOccurrencesOfString:@"Img" withString:@"Audio"];
        path = [path stringByReplacingOccurrencesOfString:@".pic" withString:@".aud"];
        NSString *pathDir = [path stringByDeletingLastPathComponent];
        system([[[NSString alloc] initWithFormat:@"mkdir -p %@", pathDir] UTF8String]);
        [voiceData writeToFile:path atomically:YES];

        NSLog(@"MYHOOK oh mypath is: %@, %@", path, voiceMsg);

        //随机得到时间
        
        int voiceRandTime = (arc4random() % 15) + 5;

        voiceMsg.m_dtVoice = [voiceData retain];
        voiceMsg.m_uiVoiceTime = voiceRandTime *1000; //1000;

        AudioSender *senderMgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"AudioSender")];

        [senderMgr ResendVoiceMsg:toUser MsgWrap:voiceMsg];

        NSLog(@"发送语音消息成功ResendVoiceMsg");
        
    });

}


%new
-(void)sendVoiceToUser{
    if(m_isChatRoom){
        NSLog(@"当前为群聊 this is clickButton:%d",m_clickButton);
    }else{
         NSLog(@"当前为个人 this is clickButton:%d",m_clickButton);
    }

    NSString *toUser = [[self GetContact] m_nsUsrName];
    NSLog(@"%@",toUser);

//    return;

    //http://www.fengchuan.net/amr/001.amr
    //http://www.fengchuan.net/amr/002.amr
    //http://www.fengchuan.net/amr/003.amr
    //http://www.fengchuan.net/amr/004.amr
    //http://www.fengchuan.net/amr/005.amr
    //http://www.fengchuan.net/amr/006.amr
    //http://www.fengchuan.net/amr/007.amr
    //http://www.fengchuan.net/amr/008.amr
    //http://www.fengchuan.net/amr/009.amr
    //http://www.fengchuan.net/amr/010.amr
    //http://www.fengchuan.net/amr/011.amr
    //http://www.fengchuan.net/amr/012.amr
    //http://www.fengchuan.net/amr/013.amr
    //http://www.fengchuan.net/amr/014.amr
    //http://www.fengchuan.net/amr/015.amr
    //http://www.fengchuan.net/amr/016.amr
    //http://www.fengchuan.net/amr/017.amr
    //http://www.fengchuan.net/amr/018.amr
    //http://www.fengchuan.net/amr/019.amr
    //http://www.fengchuan.net/amr/020.amr

    if(m_isChatRoom){
        if(m_clickButton == 1){
            [self sendVoiceMessage:toUser voiceUrl:@"http://www.fengchuan.net/amr/001.amr" voiceTime:@"5"];
        }else if(m_clickButton == 2){
            [self sendVoiceMessage:toUser voiceUrl:@"http://www.fengchuan.net/amr/002.amr" voiceTime:@"5"];
        }
        else if(m_clickButton == 3){
            [self sendVoiceMessage:toUser voiceUrl:@"http://www.fengchuan.net/amr/003.amr" voiceTime:@"5"];
        }
        else if(m_clickButton == 4){
            [self sendVoiceMessage:toUser voiceUrl:@"http://www.fengchuan.net/amr/004.amr" voiceTime:@"5"];
        }
        else if(m_clickButton == 5){
            [self sendVoiceMessage:toUser voiceUrl:@"http://www.fengchuan.net/amr/005.amr" voiceTime:@"5"];
        }
        else if(m_clickButton == 6){
            [self sendVoiceMessage:toUser voiceUrl:@"http://www.fengchuan.net/amr/006.amr" voiceTime:@"5"];
        }
        else if(m_clickButton == 7){
            [self sendVoiceMessage:toUser voiceUrl:@"http://www.fengchuan.net/amr/007.amr" voiceTime:@"5"];
        }
        else if(m_clickButton == 8){
            [self sendVoiceMessage:toUser voiceUrl:@"http://www.fengchuan.net/amr/008.amr" voiceTime:@"5"];
        }

    }else{

        if(m_clickButton == 1){
            [self sendVoiceMessage:toUser voiceUrl:@"http://www.fengchuan.net/amr/009.amr" voiceTime:@"5"];
        }else if(m_clickButton == 2){
            [self sendVoiceMessage:toUser voiceUrl:@"http://www.fengchuan.net/amr/010.amr" voiceTime:@"5"];
        }
        else if(m_clickButton == 3){
            [self sendVoiceMessage:toUser voiceUrl:@"http://www.fengchuan.net/amr/011.amr" voiceTime:@"5"];
        }
        else if(m_clickButton == 4){
            [self sendVoiceMessage:toUser voiceUrl:@"http://www.fengchuan.net/amr/012.amr" voiceTime:@"5"];
        }
        else if(m_clickButton == 5){
            [self sendVoiceMessage:toUser voiceUrl:@"http://www.fengchuan.net/amr/013.amr" voiceTime:@"5"];
        }
        else if(m_clickButton == 6){
            [self sendVoiceMessage:toUser voiceUrl:@"http://www.fengchuan.net/amr/014.amr" voiceTime:@"5"];
        }
        else if(m_clickButton == 7){
            [self sendVoiceMessage:toUser voiceUrl:@"http://www.fengchuan.net/amr/015.amr" voiceTime:@"5"];
        }
        else if(m_clickButton == 8){
            [self sendVoiceMessage:toUser voiceUrl:@"http://www.fengchuan.net/amr/016.amr" voiceTime:@"5"];
        }
    }

}
%new
-(void)showVoiceSheet{

    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: nil
                                                                              message: nil
                                                                       preferredStyle:UIAlertControllerStyleActionSheet];
    //添加Button
    [alertController addAction: [UIAlertAction actionWithTitle: @"语音 1"
                                                         style: UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *action) {
                                                           m_clickButton = 1;
                                                           [self sendVoiceToUser];

                                                       }]];
    [alertController addAction: [UIAlertAction actionWithTitle: @"语音 2"
                                                         style: UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *action){

                                                           m_clickButton = 2;
                                                           [self sendVoiceToUser];

                                                       }]];
    [alertController addAction: [UIAlertAction actionWithTitle: @"语音 3"
                                                         style: UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *action){

                                                           m_clickButton = 3;
                                                           [self sendVoiceToUser];
                                                       }]];

    [alertController addAction: [UIAlertAction actionWithTitle: @"语音 4"
                                                         style: UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *action){

                                                           m_clickButton = 4;
                                                           [self sendVoiceToUser];
                                                       }]];

    [alertController addAction: [UIAlertAction actionWithTitle: @"语音 5"
                                                         style: UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *action){

                                                           m_clickButton = 5;
                                                           [self sendVoiceToUser];
                                                       }]];

    [alertController addAction: [UIAlertAction actionWithTitle: @"语音 6"
                                                         style: UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *action){

                                                           m_clickButton = 6;
                                                           [self sendVoiceToUser];
                                                       }]];


    [alertController addAction: [UIAlertAction actionWithTitle: @"语音 7"
                                                         style: UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *action){

                                                           m_clickButton = 7;
                                                           [self sendVoiceToUser];
                                                       }]];

    [alertController addAction: [UIAlertAction actionWithTitle: @"语音 8"
                                                         style: UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *action){

                                                           m_clickButton = 8;
                                                           [self sendVoiceToUser];
                                                       }]];



    [alertController addAction: [UIAlertAction actionWithTitle: @"取消"
                                                         style: UIAlertActionStyleCancel
                                                       handler:nil]];
    
    [self presentViewController: alertController animated: YES completion: nil];
}

%new
- (void)MonitorButtonClicked {
    // NSLog(@"MYHOOK dataDict: %@ %@ , %@", self, mmDataDict, [self isChatRoomInMM] ? @"YES":@"NO");
    if (![self btn]) {
        return;
    }

   //弹出框
    [self showVoiceSheet];

}

//- (id)GetContact;  //得到用户
%end




%hook CSetting
- (id)init{
    id ret = %orig;

    NSLog(@"this is enter CSetting");

    m_nCSetting = self;

    return ret;
}
%end



