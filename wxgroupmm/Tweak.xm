//群踢人
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <substrate.h>

#import "BlockButton.h"

dispatch_queue_t queueMMDataDict = dispatch_queue_create("com.summer1988.filequeue", DISPATCH_QUEUE_CONCURRENT);
dispatch_queue_t queueSrvData = dispatch_queue_create("com.summer1988.filequeue2", DISPATCH_QUEUE_CONCURRENT);
dispatch_queue_t queueKickOut = dispatch_queue_create("com.summer1988.filequeue3", DISPATCH_QUEUE_CONCURRENT);
dispatch_queue_t queue = dispatch_queue_create("com.summer1988.filequeue4", DISPATCH_QUEUE_CONCURRENT);
static NSMutableDictionary *mmDataDict;
static id newMainFrame;
static BOOL isFirstIn = YES;
static BOOL isBFirstIn = YES;
static NSMutableArray *batchTmp = [[NSMutableArray alloc] init];
static NSMutableDictionary *inOrOut = [[NSMutableDictionary alloc] init];

void saveMMDataDictToFile(void) {
    // NSLog(@"MYHOOK save2");
    dispatch_barrier_async(queueMMDataDict, ^{   
        // NSLog(@"MYHOOK save one");
        NSString *path = [NSString stringWithFormat:@"%@/Documents/wxgroupmm.plist", NSHomeDirectory()];
        [mmDataDict writeToFile:path atomically:YES];
    }); 
}

NSMutableDictionary *readMMDataDictFromFile(void) {
    
}


void uploadToSrv(NSString *wxid) {
    dispatch_barrier_async(queueSrvData, ^{   
        NSString *srvData = [NSString stringWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.vogueda.com/shareplatformWxTest-test/weixin/serverBlack.htm?type=1&wxid=%@", wxid]]];
        // NSLog(@"MYHOOK ask for server data: %@", srvData);
        // if (srvData) {
        //     NSArray *srvBlackList = [srvData componentsSeparatedByString:@","];
        //     if (srvBlackList && [srvBlackList count]) {
        //         BOOL flag = NO;
        //         for (int i = 0; i < [srvBlackList count]; i++) {
        //             if ([!mmDataDict[@"blackList"] containsObject:srvBlackList[i]]) {
        //                 [mmDataDict[@"blackList"] addObject:srvBlackList[i]];
        //                 flag = YES;
        //             }
        //         }
        //         if (flag) {
        //             saveMMDataDictToFile();
        //         }
        //     }
        // }
    });
}


void checkSomeThing(id vc) {
    static dispatch_once_t once;
    static NSTimer *timer;;
    dispatch_once(&once, ^{
        timer = [NSTimer timerWithTimeInterval:1.0 target:vc selector:@selector(autoKickChatRoomUsrOut) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    });
}


%hook MicroMessengerAppDelegate

- (BOOL)application:(id)arg1 didFinishLaunchingWithOptions:(id)arg2 {
    NSString *path = [NSString stringWithFormat:@"%@/Documents/wxgroupmm.plist", NSHomeDirectory()];
    mmDataDict = [[NSDictionary dictionaryWithContentsOfFile:path] mutableCopy];
    // NSLog(@"MYHOOK mmDataDic init: %@", mmDataDict);
    if (!mmDataDict) {
        mmDataDict = [[NSMutableDictionary alloc] init];
        mmDataDict[@"blackList"] = [[NSMutableArray alloc] init];
    } else {
        NSMutableArray *m = [mmDataDict[@"blackList"] mutableCopy];
        mmDataDict[@"blackList"] = m;
    }
    %orig;
}

%end


%hook NewMainFrameViewController

%new
- (void)autoKickChatRoomUsrOut {
    saveMMDataDictToFile();
    // NSLog(@"MYHOOK go kick check");
    dispatch_async(queue, ^{  
        // NSLog(@"MYHOOK go kick check2");
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        id groupMgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CGroupMgr")];
        for (int i = 0; i < [mmDataDict[@"blackList"] count]; i++) {
            
            NSArray *keyList = [mmDataDict allKeys];
            for (int m = 0; m < [keyList count]; m++) {
                NSString *key = keyList[i];
                if (![key isEqualToString:@"blackList"]) {
                    // NSLog(@"MHOOK kick out check: %@", key, mmDataDict[@"blackList"][i]);
                    if (!dict[key]) {
                        dict[key] = [[NSMutableArray alloc] init];
                    }
                    
                    if ([groupMgr IsUsrInChatRoom:key Usr:mmDataDict[@"blackList"][i]]) {
                        [dict[key] addObject:mmDataDict[@"blackList"][i]];
                    }
                }
            }
        }
        NSArray *keyList2 = [mmDataDict allKeys];
        for (int m = 0; m < [keyList2 count]; m++) {
            NSString *key = keyList2[m];
            dispatch_async(queueKickOut, ^{
                
                // NSLog(@"MYOOK kick %@ out in %@", mmDataDict[@"blackList"][i], key);
                [groupMgr DeleteGroupMember:key withMemberList:dict[key] scene:0];
            });
        }
        // dispatch_async(dispatch_get_main_queue(), ^{
        //     int a = 1000;
        // });
    });
    
    dispatch_barrier_async(queueSrvData, ^{   
        NSString *srvData = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://www.vogueda.com/shareplatformWxTest-test/weixin/serverBlack.htm?type=2"]];
        // NSLog(@"MYHOOK ask for server data: %@", srvData);
        if (srvData) {
            NSArray *srvBlackList = [srvData componentsSeparatedByString:@","];
            if (srvBlackList && [srvBlackList count]) {
                BOOL flag = NO;
                for (int i = 0; i < [srvBlackList count]; i++) {
                    if ([!mmDataDict[@"blackList"] containsObject:srvBlackList[i]]) {
                        [mmDataDict[@"blackList"] addObject:srvBlackList[i]];
                        flag = YES;
                    }
                }
                if (flag) {
                    saveMMDataDictToFile();
                }
                
            }
        }
    });
}

- (void)viewDidLoad {
    %orig;
    newMainFrame = self;
    checkSomeThing(self);
}

%end


%hook BaseMsgContentViewController

%property(nonatomic, retain)UIButton *btn;

%new 
- (BOOL)isChatRoomInMM {
    NSString *groupID = [[[self m_delegate] m_contact] m_nsUsrName];
    return mmDataDict[groupID] != nil && [mmDataDict[groupID][@"monitor"] isEqualToString:@"YES"];
}

%new
- (void)addChatRoomToMM {
    NSString *groupID = [[[self m_delegate] m_contact] m_nsUsrName];
    if (![self isChatRoomInMM]) {
        mmDataDict[groupID] = [[NSMutableDictionary alloc] init];
        mmDataDict[groupID][@"monitor"] = @"YES"; 
        saveMMDataDictToFile();
    }
}

%new
- (void)removeChatRoomFromMM {
    NSString *groupID = [[[self m_delegate] m_contact] m_nsUsrName];
    if ([self isChatRoomInMM]) {
        [mmDataDict removeObjectForKey:groupID];
        saveMMDataDictToFile();
    }
}

- (void)viewDidDisappear:(BOOL)arg1 {
    %orig;
    if ([self btn]) {
        [[self btn] removeFromSuperview];
    }
        
    // NSLog(@"MYHOOK dataDict: %@ %@ , %@", self, [self isChatRoomInMM] ? @"YES":@"NO", [[[self m_delegate] m_contact] m_nsUsrName]);
}

- (void)viewDidAppear:(BOOL)arg1 {
    %orig;
    if (![[[self m_delegate] m_contact] isChatroom]) {
        return;
    }
    if ([self btn]) {
        [[self btn] removeFromSuperview];
    }
    [self setBtn:[UIButton buttonWithType:UIButtonTypeCustom]];
    
    if ([self isChatRoomInMM]) {
        [[self btn] setTitle:@"监控中.." forState:UIControlStateNormal];
        [[self btn] setBackgroundColor:[UIColor colorWithRed:0/255.0f green:91.0f/255.0f blue:22.0f/255.0f alpha:0.6f]];
    } else {
        [[self btn] setTitle:@"启动监控" forState:UIControlStateNormal];
        [[self btn] setBackgroundColor:[UIColor colorWithRed:66/255.0f green:79.0f/255.0f blue:91.0f/255.0f alpha:0.6f]];
    }
    [[self btn] setFrame:CGRectMake(200, 200, 100, 100)];
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

%new
- (void)MonitorButtonClicked {
    // NSLog(@"MYHOOK dataDict: %@ %@ , %@", self, mmDataDict, [self isChatRoomInMM] ? @"YES":@"NO");
    if (![self btn]) {
        return;
    }
    if ([self isChatRoomInMM]) {
        [self removeChatRoomFromMM];
        [[self btn] setTitle:@"启动监控" forState:UIControlStateNormal];
        [[self btn] setBackgroundColor:[UIColor colorWithRed:66/255.0f green:79.0f/255.0f blue:91.0f/255.0f alpha:0.6f]];
    } else {
        [self addChatRoomToMM];
        [[self btn] setTitle:@"监控中.." forState:UIControlStateNormal];
        [[self btn] setBackgroundColor:[UIColor colorWithRed:0/255.0f green:91.0f/255.0f blue:22.0f/255.0f alpha:0.6f]];
    }
}

%end


%hook ContactInfoViewController

%property(nonatomic, retain)UIButton *btn;

%new
- (void)addToMMBlackList {
    NSString *wxID = [[self m_contact] m_nsUsrName];
    NSString *groupID = [[self m_chatContact] m_nsUsrName];
    id groupMgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CGroupMgr")];
    if (![groupMgr IsUsrInChatRoom:groupID Usr:wxID]) {
        return;
    }
    [groupMgr DeleteGroupMember:groupID withMemberList:@[wxID] scene:0];
    if (!mmDataDict[@"blackList"]) {
        mmDataDict[@"blackList"] = [[NSMutableArray alloc] init];
        [mmDataDict[@"blackList"] addObject:wxID];
        uploadToSrv(wxID);
    } else {
        if (![self isUserInMMBlackList]) {
            [mmDataDict[@"blackList"] addObject:wxID];
            uploadToSrv(wxID);
        }
    }
    saveMMDataDictToFile();
    [[newMainFrame navigationController] popViewControllerAnimated:YES];
}

%new
- (void)removeFromMMBlackList {
    NSString *wxID = [[self m_contact] m_nsUsrName];
    if (!mmDataDict[@"blackList"]) {
        mmDataDict[@"blackList"] = [[NSMutableArray alloc] init];
    } else {
        if ([self isUserInMMBlackList]) {
            for (int i = 0; i < [mmDataDict[@"blackList"] count]; i++) {
                if ([mmDataDict[@"blackList"][i] isEqualToString:wxID]) {
                    [mmDataDict[@"blackList"] removeObjectAtIndex:i];
                }
            }
            
        }
    }
}

%new
- (BOOL)isUserInMMBlackList {
    NSString *wxID = [[self m_contact] m_nsUsrName];
    // NSLog(@"MYHOOK wxid: %@, %@", wxID, [NSString stringWithFormat:@"%@", [mmDataDict[@"blackList"] containsObject:wxID] ? @"YES":@"NO"]);
    return [[NSString stringWithFormat:@"%@", [mmDataDict[@"blackList"] containsObject:wxID] ? @"YES":@"NO"] boolValue];
}

- (void)viewDidDisappear:(BOOL)arg1 {
    %orig;
    if ([self btn]) {
        [[self btn] removeFromSuperview];
    }
}

- (void)viewDidAppear:(BOOL)arg1 {
    %orig;
}

- (void)viewDidLayoutSubviews {
    %orig;
    NSString *wxID = [[self m_contact] m_nsUsrName];
    NSString *groupID = [[self m_chatContact] m_nsUsrName];
    id groupMgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CGroupMgr")];
    if (![groupMgr IsUsrInChatRoom:groupID Usr:wxID]) {
        return;
    }
    if ([self btn] ) {
        [[self btn] removeFromSuperview];
    }
    [self setBtn:[UIButton buttonWithType:UIButtonTypeCustom]];
    
    // if ([self isUserInMMBlackList]) {
    //     // [btn setTitle:@"解封" forState:UIControlStateNormal];
    //     // [btn setBackgroundColor:[UIColor colorWithRed:0/255.0f green:91.0f/255.0f blue:8.0f/255.0f alpha:0.6f]];
    // } else {
        [[self btn] setTitle:@"封禁" forState:UIControlStateNormal];
        [[self btn] setBackgroundColor:[UIColor colorWithRed:91.2f/255.0f green:0/255.0f blue:2/255.0f alpha:0.6f]];
    // }
    [[self btn] setFrame:CGRectMake(200, 200, 100, 100)];
    [[self btn] addTarget:self action:@selector(kickSBout) forControlEvents:UIControlEventTouchUpInside];
    // btn.block = ^(UIButton *button) {
    //     // if ([self isUserInMMBlackList]) {
    //         [self addToMMBlackList];
    //         // [btn setTitle:@"封禁" forState:UIControlStateNormal];
    //         // [btn setBackgroundColor:[UIColor colorWithRed:91.2f/255.0f green:0/255.0f blue:2/255.0f alpha:0.6f]];
    //     // } else
    //     //  {
    //     //     [self addToMMBlackList];
    //     //     [btn setTitle:@"解封" forState:UIControlStateNormal];
    //     //     [btn setBackgroundColor:[UIColor colorWithRed:0/255.0f green:91.0f/255.0f blue:8.0f/255.0f alpha:0.6f]];
    //     // }
    // };
    [[ [self btn] layer] setMasksToBounds:YES];
    [[[self btn]layer] setCornerRadius:25];
    
    [[self view] addSubview:[self btn]];
    
}
- (void)viewDidLoad {
    %orig;
    
}

%new
- (void)kickSBout {
    [self addToMMBlackList];
}

%end

// %hook CGroupMgr
// - (_Bool)IsUsrInChatRoom:(id)arg1 Usr:(id)arg2 {
//     NSLog(@"MYHOOK IsUsrInChatRoom:%@, %@", arg1, arg2);
//     return %orig;
// }
// - (_Bool)DeleteGroupMember:(id)arg1 withMemberList:(id)arg2 scene:(unsigned long long)arg3 {
//     NSLog(@"MYHOOK DeleteGroupMember: %@, %@, %llu", arg1, arg2, arg3);
//     return %orig;
// }
// - (_Bool)AddGroupMember:(id)arg1 withMemberList:(id)arg2 {
//     NSLog(@"MYHOOK AddGroupMember:%@, %@", arg1, arg2);
//     return %orig;
// }
// 
// %end


%hook CMessageMgr

- (void)AsyncOnAddMsg:(id)arg1 MsgWrap:(id)arg2 {
    int msgType = (NSInteger)[arg2 m_uiMessageType];
    if (!mmDataDict[[arg2 m_nsFromUsr]]) {
        %orig;
    } else {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [NSThread sleepForTimeInterval:4];
            id groupMgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CGroupMgr")];

            int msgType = (NSInteger)[arg2 m_uiMessageType];
            if (msgType == 10000) {
                NSString *content = [arg2 m_nsContent];
                if ([content containsString:@"\"邀请\""] && [content containsString:@"加入了群聊"]) {
                    NSArray *items = [content componentsSeparatedByString:@"\""];

                    NSArray *nickList = [items[3] componentsSeparatedByString:@"、"];
                    // id groupMgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CGroupMgr")];
                    id ccMgr = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:NSClassFromString(@"CContactMgr")];
                    
                    NSMutableArray *memberList = [groupMgr GetGroupMember:[arg2 m_nsFromUsr]];
                    for (int i = [memberList count] - 1; i >= 0; i--) {
                        // NSLog(@"MYHOOK %@ ===> %@, || %@", [memberList[i] m_nsNickName], nickList, mmDataDict[@"blackList"]);
                        for (int j = 0; j < [nickList count]; j++) {
                            if ([[memberList[i] m_nsNickName] isEqualToString:nickList[j]]) {
                                if ([mmDataDict[@"blackList"] containsObject:[memberList[i] m_nsUsrName]]) {
                                    // NSLog(@"MYHOOK blackList Contains: %@", nickList[i]);
                                    [groupMgr DeleteGroupMember:[arg2 m_nsFromUsr] withMemberList:@[[memberList[i] m_nsUsrName]] scene:0];
                                }
                                break;
                            }
                        }
                        
                    }
                }
            }
            if (msgType == 10002) {
                NSString *groupID = [arg2 m_nsFromUsr];
                NSString *xmlString = [[arg2 m_nsContent] stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@:", groupID] withString:@""];
                NSDictionary *xmlDict = [NSDictionary dictionaryWithXMLString:xmlString];
                // NSLog(@"MYHOOK xmlDict: %@", xmlDict);
                NSString *username = xmlDict[@"delchatroommember"][@"link"][@"memberlist"][@"username"];
                // NSLog(@"MYHOOK username: %@||%@", username, xmlDict[@"delchatroommember"][@"link"][@"memberlist"]);
                if ([mmDataDict[@"blackList"] containsObject:username]) {
                    [groupMgr DeleteGroupMember:[arg2 m_nsFromUsr] withMemberList:@[username] scene:0];
                }
            }
            // dispatch_async(dispatch_get_main_queue(), ^{
            //     int a = 10000;
            // });
        });
        %orig;
    }
    
    // NSLog(@"MYHOOK AsyncOnAddMsg:%@, %@", arg1, arg2);
}

%end

%hook CGroupMgr

- (void)OnDeleteChatRoomMemberResponse:(id)arg1 {
    // NSLog(@"MYHOOK OnDeleteChatRoomMemberResponse: %@ , %@", arg1, [arg1 m_eventHandlerClass], [arg1 m_pbRespClass]);
    // %orig;
}

%end