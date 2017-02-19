#import <UIKIT/UIKIT.h>
#import <Foundation/Foundation.h>
#import <substrate.h>

static NSString *currentPhone = nil;                                         //当前的电话号码
static NSMutableDictionary *myResults = [[NSMutableDictionary alloc] init];  //结果数据
static NSMutableArray *quickList = [[NSMutableArray alloc] init];           //搜次数过快
static NSMutableArray *excList = [[NSMutableArray alloc] init];     //对方账户异常
static NSMutableArray *nowxList = [[NSMutableArray alloc] init];    //没有微信号
static NSMutableArray *otherList = [[NSMutableArray alloc] init];    //没有微信号

static int total = 0;
static int currNum = 0;
static UILabel *yourLabel = nil;
static int pos = 0;

static dispatch_group_t group = dispatch_group_create();
static dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);


extern "C" NSMutableDictionary * openFile(NSString * fileName) {
    //    @autoreleasepool {
    NSLog(@"HKWX file exists: %@", [[NSFileManager defaultManager] fileExistsAtPath:fileName] ? @"YES": @"NO");
    NSString *strData = [NSString stringWithContentsOfFile:fileName encoding:NSUTF8StringEncoding error:NULL];

    NSData *nsData = [strData dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSMutableDictionary *jsonData = [NSJSONSerialization
                                     JSONObjectWithData:nsData
                                     options:kNilOptions
                                     error:&error];
    return jsonData;
    //    }

}

extern "C" BOOL write2File(NSString *fileName, NSString *content) {
    [content writeToFile:fileName atomically:NO encoding:NSUTF8StringEncoding error:nil];
    return YES;
}

extern "C" NSMutableDictionary * loadTaskId() {
    return openFile(@"/var/root/als.json");
}

//URL 转码
extern "C" NSString * URLEncodedString(NSString *strData)
{
    NSString *encodedString = (NSString *)
    CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                            (CFStringRef)strData,
                                            (CFStringRef)@"!$&'()*+,-./:;=?@_~%#[]",
                                            NULL,
                                            kCFStringEncodingUTF8);
    return encodedString;
}

//发送同步群聊信息
extern "C" void syncSearchPhoneMember(NSString *data){

    //读出任务ID和orderID
    NSMutableDictionary *taskId = loadTaskId();
    NSLog(@"HKSearch loadTaskId:%@",taskId);

//    NSString *urlStr = [NSString stringWithFormat:@"http://www.vogueda.com/shareplatformWxTest/weixin/syncSearchPhoneMember.htm"];

    NSString *urlStr = [NSString stringWithFormat:@"http://www.vogueda.com/shareplatformWxTest-test/weixin/syncSearchPhoneMember.htm"];
    //把传进来的URL字符串转变为URL地址
    NSURL *url = [NSURL URLWithString:urlStr];

    //请求初始化，可以在这针对缓存，超时做出一些设置
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:20];
    NSString *sendData = (NSString *) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                                (CFStringRef)data,
                                                                                                NULL,
                                                                                                (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                kCFStringEncodingUTF8));

    NSString *parseParamsResult = [NSString stringWithFormat:@"taskId=%@&dataList=%@&type=1",[taskId objectForKey:@"taskId"],sendData];

    NSLog(@"syncSearchPhoneMember:%@",parseParamsResult);

    NSData *postData = [parseParamsResult dataUsingEncoding:NSUTF8StringEncoding];

    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];

    //创建一个新的队列（开启新线程）
    //    NSOperationQueue *queue = [NSOperationQueue new];
    //发送异步请求，请求完以后返回的数据，通过completionHandler参数来调用
    //    [NSURLConnection sendAsynchronousRequest:request
    //                                       queue:queue
    //                           completionHandler:block];


    // 3. Connection
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {

        if (connectionError == nil) {

            //　　         NSString *aString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSString *aString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

            NSLog(@"HKSearch 发送成功给服务器 %@ 服务器返回值为:%@",url,aString);

            //通知脚本当前通讯录同步完毕
            write2File(@"/var/root/hksearch/wxResult.txt", @"1");
            
        }
    }];
    
}


//发送同步群聊信息 0118前版本
extern "C" void syncSearchPhoneMember1(NSString *data){

    //读出任务ID和orderID
    NSMutableDictionary *taskId = loadTaskId();
    NSLog(@"HKSearch loadTaskId:%@",taskId);

    NSString *urlStr = [NSString stringWithFormat:@"http://www.vogueda.com/shareplatformWxTest/weixin/syncSearchPhoneMember.htm"]
    ;
    //把传进来的URL字符串转变为URL地址
    NSURL *url = [NSURL URLWithString:urlStr];

    //请求初始化，可以在这针对缓存，超时做出一些设置
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:20];

    NSString *parseParamsResult = [NSString stringWithFormat:@"taskId=%@&dataList=%@",[taskId objectForKey:@"taskId"],data];

    NSLog(@"syncSearchPhoneMember:%@",parseParamsResult);

    NSData *postData = [parseParamsResult dataUsingEncoding:NSUTF8StringEncoding];

    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];

    //创建一个新的队列（开启新线程）
    //    NSOperationQueue *queue = [NSOperationQueue new];
    //发送异步请求，请求完以后返回的数据，通过completionHandler参数来调用
    //    [NSURLConnection sendAsynchronousRequest:request
    //                                       queue:queue
    //                           completionHandler:block];


    // 3. Connection
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {

        if (connectionError == nil) {

            //　　         NSString *aString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSString *aString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

            NSLog(@"HKSearch 发送成功给服务器 %@ 服务器返回值为:%@",url,aString);

            //通知脚本当前通讯录同步完毕
            write2File(@"/var/root/hksearch/wxResult.txt", @"1");
            
        }
    }];
    
}

@interface CBaseContact
{
    NSString *m_nsUsrName;	// 8 = 0x8
    NSString *m_nsEncodeUserName;	// 16 = 0x10
    NSString *m_nsAliasName;	// 24 = 0x18
    unsigned int m_uiConType;	// 32 = 0x20
    NSString *m_nsNickName;	// 40 = 0x28
    NSString *m_nsFullPY;	// 48 = 0x30
    NSString *m_nsShortPY;	// 56 = 0x38
    NSString *m_nsRemark;	// 64 = 0x40
    NSString *m_nsRemarkPYShort;	// 72 = 0x48
    NSString *m_nsRemarkPYFull;	// 80 = 0x50
    unsigned int m_uiSex;	// 88 = 0x58
    unsigned int m_uiType;	// 92 = 0x5c
    unsigned int m_uiChatState;	// 96 = 0x60
    NSData *m_dtUsrImg;	// 104 = 0x68
    NSString *m_nsImgStatus;	// 112 = 0x70
    NSString *m_nsHDImgStatus;	// 120 = 0x78
    NSString *m_nsHeadImgUrl;	// 128 = 0x80
    NSString *m_nsHeadHDImgUrl;	// 136 = 0x88
    NSString *m_nsHeadHDMd5;	// 144 = 0x90
    NSString *m_nsDraft;	// 152 = 0x98
    unsigned int m_uiDraftTime;	// 160 = 0xa0
    NSString *m_nsAtUserList;	// 168 = 0xa8
    unsigned int m_uiQQUin;	// 176 = 0xb0
    NSString *m_nsQQNickName;	// 184 = 0xb8
    NSString *m_nsQQRemark;	// 192 = 0xc0
    NSString *m_nsMobileIdentify;	// 200 = 0xc8
    NSString *m_nsGoogleContactName;	// 208 = 0xd0
    NSString *m_nsGoogleContactNickName;	// 216 = 0xd8
    unsigned int m_uiFriendScene;	// 224 = 0xe0
    unsigned int m_uiImgKey;	// 228 = 0xe4
    unsigned int m_uiExtKey;	// 232 = 0xe8
    unsigned int m_uiImgKeyAtLastGet;	// 236 = 0xec
    unsigned int m_uiExtKeyAtLastGet;	// 240 = 0xf0
    _Bool m_hasDetectPlugin;	// 244 = 0xf4
    _Bool m_isPlugin;	// 245 = 0xf5
    _Bool m_hasDetectSelf;	// 246 = 0xf6
    _Bool m_isSelf;	// 247 = 0xf7
    NSString *m_nsAntispamTicket;	// 248 = 0xf8
    NSDictionary *_externalInfoJSONCache;	// 256 = 0x100
}

+ (void)initialize;
@property(retain, nonatomic) NSDictionary *externalInfoJSONCache; // @synthesize externalInfoJSONCache=_externalInfoJSONCache;
@property(retain, nonatomic) NSString *m_nsAntispamTicket; // @synthesize m_nsAntispamTicket;
@property(retain, nonatomic) NSString *m_nsShortPY; // @synthesize m_nsShortPY;
@property(retain, nonatomic) NSString *m_nsAtUserList; // @synthesize m_nsAtUserList;
@property(nonatomic) unsigned int m_uiDraftTime; // @synthesize m_uiDraftTime;
@property(nonatomic) unsigned int m_uiFriendScene; // @synthesize m_uiFriendScene;
@property(retain, nonatomic) NSString *m_nsGoogleContactNickName; // @synthesize m_nsGoogleContactNickName;
@property(retain, nonatomic) NSString *m_nsGoogleContactName; // @synthesize m_nsGoogleContactName;
@property(retain, nonatomic) NSString *m_nsMobileIdentify; // @synthesize m_nsMobileIdentify;
@property(retain, nonatomic) NSString *m_nsQQRemark; // @synthesize m_nsQQRemark;
@property(retain, nonatomic) NSString *m_nsQQNickName; // @synthesize m_nsQQNickName;
@property(nonatomic) unsigned int m_uiQQUin; // @synthesize m_uiQQUin;
@property(nonatomic) unsigned int m_uiExtKeyAtLastGet; // @synthesize m_uiExtKeyAtLastGet;
@property(nonatomic) unsigned int m_uiImgKeyAtLastGet; // @synthesize m_uiImgKeyAtLastGet;
@property(nonatomic) unsigned int m_uiExtKey; // @synthesize m_uiExtKey;
@property(nonatomic) unsigned int m_uiImgKey; // @synthesize m_uiImgKey;
@property(retain, nonatomic) NSString *m_nsDraft; // @synthesize m_nsDraft;
@property(retain, nonatomic) NSString *m_nsHeadHDMd5; // @synthesize m_nsHeadHDMd5;
@property(retain, nonatomic) NSString *m_nsHeadHDImgUrl; // @synthesize m_nsHeadHDImgUrl;
@property(retain, nonatomic) NSString *m_nsHeadImgUrl; // @synthesize m_nsHeadImgUrl;
@property(retain, nonatomic) NSString *m_nsHDImgStatus; // @synthesize m_nsHDImgStatus;
@property(retain, nonatomic) NSString *m_nsImgStatus; // @synthesize m_nsImgStatus;
@property(retain, nonatomic) NSData *m_dtUsrImg; // @synthesize m_dtUsrImg;
@property(nonatomic) unsigned int m_uiChatState; // @synthesize m_uiChatState;
@property(nonatomic) unsigned int m_uiType; // @synthesize m_uiType;
@property(nonatomic) unsigned int m_uiSex; // @synthesize m_uiSex;
@property(retain, nonatomic) NSString *m_nsRemarkPYFull; // @synthesize m_nsRemarkPYFull;
@property(retain, nonatomic) NSString *m_nsRemarkPYShort; // @synthesize m_nsRemarkPYShort;
@property(retain, nonatomic) NSString *m_nsRemark; // @synthesize m_nsRemark;
@property(retain, nonatomic) NSString *m_nsFullPY; // @synthesize m_nsFullPY;
@property(nonatomic) unsigned int m_uiConType; // @synthesize m_uiConType;
@property(retain, nonatomic) NSString *m_nsAliasName; // @synthesize m_nsAliasName;
@property(retain, nonatomic) NSString *m_nsEncodeUserName; // @synthesize m_nsEncodeUserName;
@property(retain, nonatomic) NSString *m_nsUsrName; // @synthesize m_nsUsrName;
@property(readonly, nonatomic) _Bool m_isPlugin; // @synthesize m_isPlugin;

- (id)localizedStringForMale:(id)arg1 female:(id)arg2 andUnkownSex:(id)arg3;
- (int)getImageStatusCode;
- (_Bool)isHasGMail;
- (id)getQQDisplayName;
- (_Bool)isHasQQDisplayName;
- (_Bool)isHasQQ;
- (_Bool)isWeixinTeamContact;
- (_Bool)isSelf;
- (_Bool)hasContactDisplayUsrNameByCache;
- (_Bool)hasContactDisplayUsrName;
- (id)getContactDisplayUsrName;
- (id)getContactTalkRoomName;
- (id)getContactDisplayName;
- (id)getRemark;
- (void)saveUserImage;
- (id)getContactHeadImage;
- (_Bool)isNeedGetHDImg;
- (_Bool)isHasHDImg;
- (_Bool)isNeedGetUsrImgWithoutCheckLocalFile;
- (_Bool)isNeedGetUsrImg;
- (_Bool)isEnterpriseContact;
- (_Bool)isWeSportContact;
- (_Bool)isChatStatusNotifyOpen;
- (_Bool)isMacHelper;
- (_Bool)isQQ;
- (_Bool)isQQMBlog;
- (_Bool)isTemplateMsgHolder;
- (_Bool)isFileHelper;
- (_Bool)isBrandSessionHolder;
- (_Bool)isGroupCard;
- (_Bool)isChatroom;
- (_Bool)isLbsroom;
- (_Bool)isWeixin;
- (_Bool)isMMContact;
- (_Bool)isFavour;
- (void)setSnsBlack:(_Bool)arg1;
- (_Bool)isSnsBlack;
- (void)setBlack:(_Bool)arg1;
- (_Bool)isBlack;
- (_Bool)isEqualToName:(id)arg1;
- (_Bool)isEqualToContact:(id)arg1;
- (id)getEncodeUserName;
- (_Bool)isValid;
- (void)setChatRoomTopic:(id)arg1;
- (id)chatRoomTopic;
- (long long)compare:(id)arg1;
@property(readonly, copy) NSString *description;
- (_Bool)copyFrom:(id)arg1;
- (id)initWithCoder:(id)arg1;
- (void)encodeWithCoder:(id)arg1;
- (id)init;
- (void)setRemarkWithoutEmojiChange:(id)arg1;
- (void)setNickNameWithoutEmojiChange:(id)arg1;
@property(retain, nonatomic) NSString *m_nsNickName; // @synthesize m_nsNickName;
- (id)getValueTypeTable;

@end

@interface CContact : CBaseContact
{
    unsigned int m_uiChatRoomStatus;	// 264 = 0x108
    NSString *m_nsChatRoomMemList;	// 272 = 0x110
    unsigned int m_uiChatRoomMaxCount;	// 280 = 0x118
    unsigned int m_uiChatRoomVersion;	// 284 = 0x11c
//    ChatRoomDetail *m_ChatRoomDetail;	// 288 = 0x120
    NSString *m_nsChatRoomData;	// 296 = 0x128
//    ChatRoomData *m_ChatRoomData;	// 304 = 0x130
    NSString *m_nsCountry;	// 312 = 0x138
    NSString *m_nsProvince;	// 320 = 0x140
    NSString *m_nsCity;	// 328 = 0x148
    NSString *m_nsSignature;	// 336 = 0x150
    unsigned int m_uiCertificationFlag;	// 344 = 0x158
    NSString *m_nsCertificationInfo;	// 352 = 0x160
    NSString *m_nsOwner;	// 360 = 0x168
    NSString *m_nsWeiboAddress;	// 368 = 0x170
    NSString *m_nsWeiboNickName;	// 376 = 0x178
    unsigned int m_uiWeiboFlag;	// 384 = 0x180
    NSString *m_nsFBNickName;	// 392 = 0x188
    NSString *m_nsFBID;	// 400 = 0x190
    unsigned int m_uiNeedUpdate;	// 408 = 0x198
    NSString *m_nsWCBGImgObjectID;	// 416 = 0x1a0
    int m_iWCFlag;	// 424 = 0x1a8
    NSString *m_pcWCBGImgID;	// 432 = 0x1b0
    NSString *m_nsExternalInfo;	// 440 = 0x1b8
    NSString *m_nsBrandSubscriptConfigUrl;	// 448 = 0x1c0
    unsigned int m_uiBrandSubscriptionSettings;	// 456 = 0x1c8
//    SubscriptBrandInfo *m_subBrandInfo;	// 464 = 0x1d0
    NSString *m_nsBrandIconUrl;	// 472 = 0x1d8
    _Bool m_isExtInfoValid;	// 480 = 0x1e0
    NSDictionary *externalInfoJSONCache;	// 488 = 0x1e8
    _Bool m_isShowRedDot;	// 496 = 0x1f0
    NSString *m_nsMobileHash;	// 504 = 0x1f8
    NSString *m_nsMobileFullHash;	// 512 = 0x200
    NSString *m_nsLinkedInID;	// 520 = 0x208
    NSString *m_nsLinkedInName;	// 528 = 0x210
    NSString *m_nsLinkedInPublicUrl;	// 536 = 0x218
    unsigned int m_uiDeleteFlag;	// 544 = 0x220
    NSString *m_nsDescription;	// 552 = 0x228
    NSString *m_nsCardUrl;	// 560 = 0x230
    NSString *m_nsWorkID;	// 568 = 0x238
    NSString *m_nsLabelIDList;	// 576 = 0x240
    NSArray *m_arrPhoneItem;	// 584 = 0x248
    _Bool _m_bFromNewDB;	// 592 = 0x250
    unsigned int _m_uiLastUpdate;	// 596 = 0x254
    unsigned int _m_uiMetaFlag;	// 600 = 0x258
    NSString *m_nsWeiDianInfo;	// 608 = 0x260
    NSDictionary *_m_dicWeiDianInfo;	// 616 = 0x268
}

+ (_Bool)isHeadImgUpdated:(id)arg1 Local:(id)arg2;
+ (void)HandleChatMemUsrImg:(struct tagMMModChatRoomMember *)arg1 Contatct:(id)arg2 DocPath:(id)arg3;
+ (void)HandleUsrImgPB:(id)arg1 Contatct:(id)arg2 DocPath:(id)arg3;
+ (void)HandleUsrImg:(struct tagMMModContact *)arg1 Contatct:(id)arg2 DocPath:(id)arg3;
+ (id)genChatRoomName:(id)arg1;
+ (id)getChatRoomMemberWithoutMyself:(id)arg1;
+ (id)getChatRoomMember:(id)arg1;
+ (unsigned long long)getChatRoomMemberCount:(id)arg1;
+ (id)getMicroBlogUsrDisplayName:(id)arg1;
+ (id)parseContactKey:(id)arg1;
+ (id)SubscriptedBrandsFromString:(id)arg1;
+ (void)initialize;
@property(nonatomic) unsigned int m_uiMetaFlag; // @synthesize m_uiMetaFlag=_m_uiMetaFlag;
@property(nonatomic) unsigned int m_uiLastUpdate; // @synthesize m_uiLastUpdate=_m_uiLastUpdate;
@property(nonatomic) _Bool m_bFromNewDB; // @synthesize m_bFromNewDB=_m_bFromNewDB;
@property(retain, nonatomic) NSString *m_nsWorkID; // @synthesize m_nsWorkID;
@property(retain, nonatomic) NSString *m_nsWeiDianInfo; // @synthesize m_nsWeiDianInfo;
//@property(retain, nonatomic) ChatRoomDetail *m_ChatRoomDetail; // @synthesize m_ChatRoomDetail;
@property(retain, nonatomic) NSArray *m_arrPhoneItem; // @synthesize m_arrPhoneItem;
@property(retain, nonatomic) NSString *m_nsLabelIDList; // @synthesize m_nsLabelIDList;
@property(retain, nonatomic) NSString *m_nsCardUrl; // @synthesize m_nsCardUrl;
@property(retain, nonatomic) NSString *m_nsDescription; // @synthesize m_nsDescription;
@property(nonatomic) unsigned int m_uiDeleteFlag; // @synthesize m_uiDeleteFlag;
@property(nonatomic) unsigned int m_uiChatRoomVersion; // @synthesize m_uiChatRoomVersion;
@property(nonatomic) unsigned int m_uiChatRoomMaxCount; // @synthesize m_uiChatRoomMaxCount;
@property(retain, nonatomic) NSString *m_nsLinkedInPublicUrl; // @synthesize m_nsLinkedInPublicUrl;
@property(retain, nonatomic) NSString *m_nsLinkedInName; // @synthesize m_nsLinkedInName;
@property(retain, nonatomic) NSString *m_nsLinkedInID; // @synthesize m_nsLinkedInID;
@property(retain, nonatomic) NSString *m_nsMobileFullHash; // @synthesize m_nsMobileFullHash;
@property(retain, nonatomic) NSString *m_nsMobileHash; // @synthesize m_nsMobileHash;
@property(nonatomic) _Bool m_isShowRedDot; // @synthesize m_isShowRedDot;
//@property(retain, nonatomic) ChatRoomData *m_ChatRoomData; // @synthesize m_ChatRoomData;
@property(retain, nonatomic) NSString *m_nsChatRoomData; // @synthesize m_nsChatRoomData;
@property(nonatomic) _Bool m_isExtInfoValid; // @synthesize m_isExtInfoValid;
@property(retain, nonatomic) NSString *m_nsBrandIconUrl; // @synthesize m_nsBrandIconUrl;
//@property(retain, nonatomic) SubscriptBrandInfo *m_subBrandInfo; // @synthesize m_subBrandInfo;
@property(nonatomic) unsigned int m_uiBrandSubscriptionSettings; // @synthesize m_uiBrandSubscriptionSettings;
@property(retain, nonatomic) NSString *m_nsBrandSubscriptConfigUrl; // @synthesize m_nsBrandSubscriptConfigUrl;
@property(retain, nonatomic) NSString *m_nsExternalInfo; // @synthesize m_nsExternalInfo;
@property(retain, nonatomic) NSString *m_pcWCBGImgID; // @synthesize m_pcWCBGImgID;
@property(nonatomic) int m_iWCFlag; // @synthesize m_iWCFlag;
@property(retain, nonatomic) NSString *m_nsWCBGImgObjectID; // @synthesize m_nsWCBGImgObjectID;
@property(nonatomic) unsigned int m_uiNeedUpdate; // @synthesize m_uiNeedUpdate;
@property(retain, nonatomic) NSString *m_nsFBID; // @synthesize m_nsFBID;
@property(retain, nonatomic) NSString *m_nsFBNickName; // @synthesize m_nsFBNickName;
@property(nonatomic) unsigned int m_uiWeiboFlag; // @synthesize m_uiWeiboFlag;
@property(retain, nonatomic) NSString *m_nsWeiboNickName; // @synthesize m_nsWeiboNickName;
@property(retain, nonatomic) NSString *m_nsWeiboAddress; // @synthesize m_nsWeiboAddress;
@property(retain, nonatomic) NSString *m_nsOwner; // @synthesize m_nsOwner;
@property(retain, nonatomic) NSString *m_nsCertificationInfo; // @synthesize m_nsCertificationInfo;
@property(nonatomic) unsigned int m_uiCertificationFlag; // @synthesize m_uiCertificationFlag;
@property(retain, nonatomic) NSString *m_nsSignature; // @synthesize m_nsSignature;
@property(retain, nonatomic) NSString *m_nsCity; // @synthesize m_nsCity;
@property(retain, nonatomic) NSString *m_nsProvince; // @synthesize m_nsProvince;
@property(retain, nonatomic) NSString *m_nsCountry; // @synthesize m_nsCountry;
@property(nonatomic) unsigned int m_uiChatRoomStatus; // @synthesize m_uiChatRoomStatus;
@property(retain, nonatomic) NSString *m_nsChatRoomMemList; // @synthesize m_nsChatRoomMemList;
@property(readonly, nonatomic) NSDictionary *m_dicWeiDianInfo; // @synthesize m_dicWeiDianInfo=_m_dicWeiDianInfo;
@property(readonly, copy) NSString *description;

- (void)setExternalInfoJSONCache:(id)arg1;
- (id)externalInfoJSONCache;
- (_Bool)IsUserInChatRoom:(id)arg1;
- (id)getLabelIDList;
- (_Bool)isAccountDeleted;
- (_Bool)isHasWeiDian;
- (_Bool)isShowLinkedIn;
- (_Bool)needShowUnreadCountOnSession;
- (void)setChatStatusNotifyOpen:(_Bool)arg1;
- (_Bool)isChatStatusNotifyOpen;
- (_Bool)isContactFrozen;
- (_Bool)isContactSessionTop;
- (_Bool)isShowChatRoomDisplayName;
- (_Bool)isAdmin;
- (id)xmlForMessageWrapContent;
- (id)getChatRoomMembrGroupNickName:(id)arg1;
- (id)getChatRoomMemberNickName:(id)arg1;
- (id)getChatRoomMemberDisplayName:(id)arg1;
- (id)getNormalContactDisplayDesc;
- (long long)compareForFavourGroup:(id)arg1;
- (_Bool)isLocalizedContact;
- (_Bool)isHolderContact;
- (_Bool)isVerified;
- (_Bool)isIgnoreBrandContat;
- (_Bool)isVerifiedBrandContact;
- (_Bool)isBrandContact;
- (_Bool)IsAddFromShake;
- (_Bool)IsAddFromLbs;
- (_Bool)isMyContact;
- (void)tryLoadExtInfo;
- (_Bool)copyPatialFieldFromContact:(id)arg1;
- (_Bool)copyFieldFromContact:(id)arg1;
- (id)initWithCoder:(id)arg1;
- (void)encodeWithCoder:(id)arg1;
- (id)initWithModContact:(id)arg1;
- (id)initWithShareCardMsgWrapContent:(id)arg1;
- (id)initWithShareCardMsgWrap:(id)arg1;
- (void)genContactFromShareCardMsgWrapContent:(id)arg1;
- (_Bool)genContactFromShareCardMsgWrap:(id)arg1;
- (id)init;
- (_Bool)isHasMobile;
- (id)getMobileList;
- (_Bool)hasMatchHashPhone;
- (id)getMobileNumString;
- (id)getMobileDisplayName;
- (_Bool)isContactTypeShouldDelete;
- (id)getNewChatroomData;
- (void)setSignatureWithoutEmojiChange:(id)arg1;
- (void)setChatRoomDataWithoutEmojiChange:(id)arg1;
//- (const map_0e718273 *)getValueTagIndexMap;
- (id)getValueTypeTable;

@end

//账号异常
@interface WXPBGeneratedMessage
- (id)init;
- (id)baseResponse;
@end

@interface BaseResponseErrMsg : WXPBGeneratedMessage
+ (void)initialize;
// Remaining properties
@property(nonatomic) int action; // @dynamic action;
@property(retain, nonatomic) NSString *cancel; // @dynamic cancel;
@property(retain, nonatomic) NSString *content; // @dynamic content;
@property(nonatomic) unsigned int countdown; // @dynamic countdown;
@property(nonatomic) int delayConnSec; // @dynamic delayConnSec;
@property(nonatomic) int dispSec; // @dynamic dispSec;
@property(retain, nonatomic) NSString *ok; // @dynamic ok;
@property(nonatomic) int showType; // @dynamic showType;
@property(retain, nonatomic) NSString *title; // @dynamic title;
@property(retain, nonatomic) NSString *url; // @dynamic url;

@end


@interface SearchContactDataProvider 
{
    _Bool _isFromAddFriendScene;	// 8 = 0x8
    // id <SearchContactDataProviderDelegate> _delegate;	// 16 = 0x10
    NSString *_keyword;	// 24 = 0x18
    CContact *_contact;	// 32 = 0x20
    NSString *_svrErrorMsg;	// 40 = 0x28
}

@property(retain, nonatomic) NSString *svrErrorMsg; // @synthesize svrErrorMsg=_svrErrorMsg;
@property(retain, nonatomic) CContact *contact; // @synthesize contact=_contact;
@property(retain, nonatomic) NSString *keyword; // @synthesize keyword=_keyword;
// @property(nonatomic) __weak id <SearchContactDataProviderDelegate> delegate; // @synthesize delegate=_delegate;
@property(nonatomic) _Bool isFromAddFriendScene; 

@end

@interface MMUISearchBar : UISearchBar
{
    _Bool m_bForceAdjustFrame;	// 8 = 0x8
}

@property(nonatomic) _Bool m_bForceAdjustFrame; // @synthesize m_bForceAdjustFrame;
- (id)findPlaceHolderIcon:(id)arg1;
- (id)findCancelButton;
- (id)getNavigationButton:(id)arg1;
- (void)fixOrientationBug;
- (void)fixSearchIconSize;
- (id)findUISearchBarImage:(id)arg1;
- (id)findUISearchBarBackground:(id)arg1;
- (id)findUISearchBarTextFieldLabel:(id)arg1;
- (void)setFrame:(struct CGRect)arg1;
- (id)init;

@end

@interface MMSearchBar
{
    // id <MMSearchBarDelegate> m_delegate;	// 8 = 0x8
    NSString *m_nsLastSearchText;	// 16 = 0x10
    MMUISearchBar *m_searchBar;	// 24 = 0x18
    NSMutableArray *m_arrFilteredObject;	// 32 = 0x20
    // UISearchDisplayController *m_searchDisplayController;	// 40 = 0x28
    // MMUIViewController *m_viewController;	// 48 = 0x30
    long long m_returnKeyType;	// 56 = 0x38
    _Bool m_isShouldRemoveDimmingView;	// 64 = 0x40
}

@property(nonatomic) long long m_returnKeyType; // @synthesize m_returnKeyType;
@property(retain, nonatomic) MMUISearchBar *m_searchBar; // @synthesize m_searchBar;
// @property(retain, nonatomic) UISearchDisplayController *m_searchDisplayController; // @synthesize m_searchDisplayController;
@property(retain, nonatomic) NSString *m_nsLastSearchText; // @synthesize m_nsLastSearchText;
// @property(nonatomic) __weak id <MMSearchBarDelegate> m_delegate; // @synthesize m_delegate;
@end

@interface FindContactSearchViewCellInfo 
{
    MMSearchBar *m_searchBar;
}

@property(nonatomic) _Bool bHasOperateOnlineResult; // @synthesize bHasOperateOnlineResult=_bHasOperateOnlineResult;
@property(nonatomic) _Bool bHasShownWebSearchCell; // @synthesize bHasShownWebSearchCell=_bHasShownWebSearchCell;
// @property(retain, nonatomic) FTSWebSearchController *webSearchLogicController; // @synthesize webSearchLogicController=_webSearchLogicController;
@property(nonatomic) _Bool bShowNoResult; // @synthesize bShowNoResult=_bShowNoResult;
@property(nonatomic) _Bool isSearching; // @synthesize isSearching=_isSearching;
@property(nonatomic) _Bool didSearchContactDone; // @synthesize didSearchContactDone=_didSearchContactDone;
// @property(retain, nonatomic) MMUILabel *nonResultLabel; // @synthesize nonResultLabel=_nonResultLabel;
@property(retain, nonatomic) SearchContactDataProvider *searchContactDataProvider; // @synthesize searchContactDataProvider=_searchContactDataProvider;
@property(nonatomic) unsigned long long searchContactState; // @synthesize searchContactState=_searchContactState;
@property(retain, nonatomic) CContact *foundContact; // @synthesize foundContact=_foundContact;
@property(retain, nonatomic) NSString *m_nsUserNameToFind; // @synthesize m_nsUserNameToFind;
@property(retain, nonatomic) UITextField *m_userNameTextField; // @synthesize m_userNameTextField;

- (void)logWebSearchClickByKeyword:(id)arg1 clickType:(unsigned int)arg2;
- (void)onWebSearchViewDidShow;
- (void)onWebSearchViewDidPop;
- (void)onWebSearchViewWillPop;
- (void)onWebSearchViewReturn:(_Bool)arg1;
- (void)endSearch;
- (void)removeWebSearchView;
- (void)onGetSearchDetailPageResponse:(id)arg1 eventID:(unsigned int)arg2;
- (void)do_LogExt:(int)arg1;
- (void)onSearchResultViewNeedStartWebSearch;
- (void)onSearchResultViewNeedPushViewController:(id)arg1;
- (void)onSearchResultViewNeedReload;
- (void)openContactInfoViewForGoogle:(id)arg1;
- (void)openContactInfoViewForPhone:(id)arg1;
- (void)showContactInfoView:(id)arg1;
- (void)showWebSearchEntryWithSrvErrMsg:(id)arg1;
- (void)showContactListInfoView:(id)arg1;
- (void)onGetNonResult;
- (void)SearchBarBecomeUnActive;
- (void)SearchBarBecomeActive;
- (void)onSearch:(id)arg1;
- (_Bool)isValidLocalQuery:(id)arg1;
- (void)removeNoResultLabelWhenSearching;
- (_Bool)searchKeyMatchesCommand:(id)arg1;
- (_Bool)allTextIsBlank;
- (void)newMessageFromContactInfo:(id)arg1;
- (void)addToContactsFromContactInfo:(id)arg1;
- (void)addFriendScene:(id)arg1;
- (_Bool)isBestGuessPhoneNumber:(id)arg1;
- (_Bool)isObj:(id)arg1 match:(id)arg2;
- (id)filterUserName:(id)arg1;
- (NSString *)getSearchBarText;
- (void)stopLoading;
- (void)startLoading;
- (void)MessageReturn:(id)arg1 Event:(unsigned int)arg2;
- (void)sendBrandContactListRequest;
- (void)onGetSearchContactRet:(id)arg1 req:(id)arg2;
- (void)doSearch;
- (void)didSearchViewTableSelect:(id)arg1;
- (double)heightForSearchViewTable:(id)arg1;
- (id)cellForIndex:(id)arg1 ForSearchViewTable:(id)arg2;
- (id)getAddressBookPersonImage:(id)arg1;
- (id)titleForHeaderInSection:(long long)arg1 ForSearchViewTable:(id)arg2;
- (id)viewForHeaderInSection:(long long)arg1 ForSearchViewTable:(id)arg2;
- (double)heightForHeaderInSection:(long long)arg1 ForSearchViewTable:(id)arg2;
- (long long)numberOfRowsInSection:(long long)arg1 ForSearchViewTable:(id)arg2;
- (long long)numberOfSectionsForSearchViewTable:(id)arg1;
- (void)mmSearchDisplayControllerDidHideSearchResultsTableView:(id)arg1;
- (void)mmSearchDisplayControllerWillShowSearchResultsTableView:(id)arg1;
- (void)hideDimmingView;
- (void)setSearchDisplayControllerContainerViewIn:(id)arg1 hidden:(_Bool)arg2;
- (void)mmSearchDisplayControllerWillEndSearch;
- (void)cancelSearch;
- (void)mmsearchBarCancelButtonClicked:(id)arg1;
- (void)mmSearchDisplayControllerDidBeginSearch;
- (void)mmSearchDisplayControllerWillBeginSearch;
- (void)mmsearchBarSearchButtonClicked:(id)arg1;
- (void)doSearch:(id)arg1 Pre:(_Bool)arg2;
- (id)makeEntryCell:(id)arg1;
- (void)makeCell:(id)arg1;
- (_Bool)becomeFirstResponder;
- (_Bool)resignFirstResponder;
- (void)handleRotate;
- (void)layoutViews;
- (id)initWithContentController:(id)arg1 backGroundView:(id)arg2;
- (void)dealloc;
- (NSMutableDictionary *)loadMySettings;
- (void)createMyButton;

@end


void saveSatistics() {

    if ([excList count]) {
        NSString *excString = [excList componentsJoinedByString:@"\n"];
        [excString writeToFile:@"/var/root/hksearch/exc" atomically:YES encoding:NSUTF8StringEncoding error:nil];
    } else {
        system([[NSString stringWithFormat:@"echo '' > %@ &", @"/var/root/hksearch/exc"] UTF8String]);

    }
    if ([quickList count]) {

        NSString *quickString = [quickList componentsJoinedByString:@"\n"];
        [quickString writeToFile:@"/var/root/hksearch/quick" atomically:YES encoding:NSUTF8StringEncoding error:nil];
    } else {
        system([[NSString stringWithFormat:@"echo '' > %@ &", @"/var/root/hksearch/quick"] UTF8String]);

    }
    
    if ([nowxList count]) {

        NSString *nowxString = [nowxList componentsJoinedByString:@"\n"];
        [nowxString writeToFile:@"/var/root/hksearch/nowx" atomically:YES encoding:NSUTF8StringEncoding error:nil];
    } else {
        system([[NSString stringWithFormat:@"echo '' > %@ &", @"/var/root/hksearch/nowx"] UTF8String]);

    }
    
    if ([myResults count]) {

        NSData *data = [NSJSONSerialization dataWithJSONObject:myResults options:NSJSONWritingPrettyPrinted error:nil];
        NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [jsonString writeToFile:@"/var/root/hksearch/results.json" atomically:NO encoding:NSUTF8StringEncoding error:nil];
    } else {
        system([[NSString stringWithFormat:@"echo '' > %@ &", @"/var/root/hksearch/results.json"] UTF8String]);

    }
    system([[NSString stringWithFormat:@"echo '%i:%i:%i:%i-%i/%i' > /var/root/hksearch/count", (int)[excList count], (int)[quickList count], (int)[nowxList count], (int)[myResults count], pos, total] UTF8String]);
}

%hook FindContactSearchViewCellInfo

- (void)viewDidLoad {
    %orig;
    if (yourLabel == nil) {
        // yourLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 25, 80, 30)];
        // [self createMyButton];
    }
}

- (void)endSearch {
    %orig;

    NSMutableDictionary *taskId = loadTaskId();
    NSLog(@"HKSearch loadTaskId:%@",taskId);
    if([[taskId objectForKey:@"type"] intValue] != 36){
        NSLog(@"HKSearch 当前不是搜索任务");
        return;
    }

//    NSString *strData = [NSString stringWithFormat:@"%@",myResults];
    NSMutableArray *jsonArray = [[NSMutableArray alloc] init];

    NSEnumerator *enumerator = [myResults keyEnumerator];
    id key = [enumerator nextObject];
    while (key) {
        id obj = [myResults objectForKey:key];
        [jsonArray addObject:obj];
        key = [enumerator nextObject];
    }

    NSData *data = [NSJSONSerialization dataWithJSONObject:jsonArray options:nil error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@",jsonString);
    syncSearchPhoneMember(jsonString);

    myResults = [[NSMutableDictionary alloc] init];
    excList = [[NSMutableArray alloc] init];
    quickList = [[NSMutableArray alloc] init];
    nowxList = [[NSMutableArray alloc] init];
    otherList = [[NSMutableArray alloc] init];
    pos = 0;
    currNum = 0;
    total = 0;
    currentPhone = nil;
}

- (void)showWebSearchEntryWithSrvErrMsg:(id)arg1 {

    NSMutableDictionary *taskId = loadTaskId();
    NSLog(@"HKSearch loadTaskId:%@",taskId);
    if([[taskId objectForKey:@"type"] intValue] != 36){
        NSLog(@"HKSearch 当前不是搜索任务");

        %orig;
        return;
    }

    NSLog(@"HKSearch showWebSearchEntryWithSrvErrMsg: %@", arg1);
    
    NSMutableDictionary *preferences = [self loadMySettings];
    if (!preferences || ![[preferences objectForKey:@"enable"] isEqualToString:@"YES"]) {
        %orig;
        pos = 0;
        currentPhone = nil;
        myResults = [[NSMutableDictionary alloc] init];
        excList = [[NSMutableArray alloc] init];
        quickList = [[NSMutableArray alloc] init];
        nowxList = [[NSMutableArray alloc] init];
        otherList = [[NSMutableArray alloc] init];

        currNum = 0;
        total = 0;
    } else {
        NSArray *phoneList = [[preferences objectForKey:@"phoneList"] retain];
        // NSArray *phoneList = @[@"13281250010", @"15902874643", @"13309059010"];
        NSMutableDictionary *contact = [[NSMutableDictionary alloc] init];
        if ([phoneList count]) {
            if ([arg1 containsString:@"帐号状态异常"]) {
                [excList addObject:phoneList[pos]];
                contact[@"state"] = @"3";
//                myResults[phoneList[pos]] = [contact retain];

            }else if ([arg1 containsString:@"操作过于频繁"]) {
                [quickList addObject:phoneList[pos]];
                contact[@"state"] = @"4";
//                myResults[phoneList[pos]] = [contact retain];

                saveSatistics();
                int excBigNum = [[preferences objectForKey:@"excMaxNum"] intValue];
                if ([quickList count] >= excBigNum) {
                    [self endSearch];
                    return;
                }
            }else{
                [otherList addObject:phoneList[pos]];
                contact[@"state"] = @"5";
//                myResults[phoneList[pos]] = [contact retain];
            }

            contact[@"phoneNum"] = [phoneList[pos] retain];
            myResults[phoneList[pos]] = [contact retain];

            saveSatistics();
            yourLabel.text = [NSString stringWithFormat:@"%i/%i", pos, (int)[phoneList count]];
            pos++;
            if (pos >= [phoneList count]) {
                NSLog(@"HKSearch oh myresults: %@ otherList:%@ quickList:%@ excList:%@ nowxList:%@", myResults,otherList,quickList,excList,nowxList);
                // [myResults writeToFile:@"/var/root/wxsearch_results.json" atomically:YES];
                // NSData *data = [NSJSONSerialization dataWithJSONObject:myResults options:NSJSONWritingPrettyPrinted error:nil];
                // NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                // [jsonString writeToFile:@"/var/root/wxsearch_results.json" atomically:NO encoding:NSUTF8StringEncoding error:nil];
                saveSatistics();
//                myResults = [[NSMutableDictionary alloc] init];
//                excList = [[NSMutableArray alloc] init];
//                quickList = [[NSMutableArray alloc] init];
//                nowxList = [[NSMutableArray alloc] init];
//                otherList = [[NSMutableArray alloc] init];

                pos = 0;
                currNum = 0;
                total = 0;
                currentPhone = nil;
                [self endSearch];
            } else {
                currentPhone = phoneList[pos];
                int randomMax = [[preferences objectForKey:@"randomMax"] intValue];
                int interval = [[preferences objectForKey:@"interval"] intValue] + arc4random() % randomMax;
                MMSearchBar *bar = MSHookIvar<MMSearchBar *>(self, "m_searchBar");
                [NSThread sleepForTimeInterval:interval];
                [bar.m_searchBar setText:[currentPhone retain]];
                [self SearchBarBecomeActive];
            }
        }

    }
}

%new
- (NSMutableDictionary *)loadMySettings {
    NSMutableDictionary *preferences = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/root/wxsearch.plist"];
    // NSLog(@"HKSearch load preferences: %@", preferences);
    if (preferences) {
        return [preferences retain];
    }
    return nil;
}

//该用户不存在
- (void)onGetNonResult {

    NSMutableDictionary *taskId = loadTaskId();
    NSLog(@"HKSearch loadTaskId:%@",taskId);
    if([[taskId objectForKey:@"type"] intValue] != 36){
        NSLog(@"HKSearch 当前不是搜索任务");

        %orig;
        return;
    }

    NSLog(@"该用户不存在");

    NSMutableDictionary *preferences = [self loadMySettings];
    if (!preferences || ![[preferences objectForKey:@"enable"] isEqualToString:@"YES"]) {

        pos = 0;
        currentPhone = nil;
        myResults = [[NSMutableDictionary alloc] init];
        excList = [[NSMutableArray alloc] init];
        quickList = [[NSMutableArray alloc] init];
        nowxList = [[NSMutableArray alloc] init];
        otherList = [[NSMutableArray alloc] init];

        currNum = 0;
        total = 0;
    } else {
        NSArray *phoneList = [[preferences objectForKey:@"phoneList"] retain];
        // NSArray *phoneList = @[@"13281250010", @"15902874643", @"13309059010"];
        if ([phoneList count]) {
            [nowxList addObject:phoneList[pos]];

            NSMutableDictionary *contact = [[NSMutableDictionary alloc] init];
            contact[@"phoneNum"] = [phoneList[pos] retain];
            contact[@"state"] = @"2";
            myResults[phoneList[pos]] = [contact retain];
            
            saveSatistics();
            yourLabel.text = [NSString stringWithFormat:@"%i/%i", pos, (int)[phoneList count]];
            pos++;
            if (pos >= [phoneList count]) {
                NSLog(@"HKSearch oh myresults: %@", myResults);
                // [myResults writeToFile:@"/var/root/wxsearch_results.json" atomically:YES];
                // NSData *data = [NSJSONSerialization dataWithJSONObject:myResults options:NSJSONWritingPrettyPrinted error:nil];
                // NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                // [jsonString writeToFile:@"/var/root/wxsearch_results.json" atomically:NO encoding:NSUTF8StringEncoding error:nil];
                saveSatistics();
//                myResults = [[NSMutableDictionary alloc] init];
//                excList = [[NSMutableArray alloc] init];
//                quickList = [[NSMutableArray alloc] init];
//                nowxList = [[NSMutableArray alloc] init];
//                otherList = [[NSMutableArray alloc] init];

                pos = 0;
                currNum = 0;
                total = 0;
                currentPhone = nil;
                [self endSearch];
            } else {
                currentPhone = phoneList[pos];
                int randomMax = [[preferences objectForKey:@"randomMax"] intValue];
                int interval = [[preferences objectForKey:@"interval"] intValue] + arc4random() % randomMax;
                MMSearchBar *bar = MSHookIvar<MMSearchBar *>(self, "m_searchBar");
                [NSThread sleepForTimeInterval:interval];
                [bar.m_searchBar setText:[currentPhone retain]];
                [self SearchBarBecomeActive];
            }
        }

    }


    NSLog(@"HKSearch -onGetNonResult: currentPhone: %@, %i", currentPhone, pos);

}

- (BOOL)allTextIsBlank {
    BOOL res = %orig;
    NSLog(@"HKSearch alltext isblank: %@", res ? @"YES":@"NO");
    return NO;
}

%new
- (void)createMyButton {
    
    [yourLabel setTextColor:[UIColor redColor]];
    [yourLabel setBackgroundColor:[UIColor whiteColor]];
    [yourLabel setFont:[UIFont fontWithName: @"0/0" size: 14.0f]];

    [[[[[[UIApplication sharedApplication] delegate] window] rootViewController] view] addSubview:yourLabel];
}

- (void)showContactInfoView:(id)arg1 {

    NSMutableDictionary *taskId = loadTaskId();
    NSLog(@"HKSearch loadTaskId:%@",taskId);
    if([[taskId objectForKey:@"type"] intValue] != 36){
        NSLog(@"HKSearch 当前不是搜索任务");

        %orig;
        return;
    }


    NSLog(@"HKSearch -showContactInfoView  oh find contact: %@,%i, %@, %@", currentPhone, pos, arg1, [arg1 getMobileNumString]);
    NSMutableDictionary *preferences = [self loadMySettings];
    
    if (!preferences || ![[preferences objectForKey:@"enable"] isEqualToString:@"YES"]) {
        %orig;
        pos = 0;
        currentPhone = nil;
        myResults = [[NSMutableDictionary alloc] init];
        excList = [[NSMutableArray alloc] init];
        quickList = [[NSMutableArray alloc] init];
        nowxList = [[NSMutableArray alloc] init];
        otherList = [[NSMutableArray alloc] init];

        currNum = 0;
        total = 0;
    } else {
        
        NSArray *phoneList = [[preferences objectForKey:@"phoneList"] retain];
        // NSArray *phoneList = @[@"13281250010", @"15902874643", @"13309059010"];
        if ([phoneList count]) {
            NSMutableDictionary *contact = [[NSMutableDictionary alloc] init];
            contact[@"usrname"] = [arg1 m_nsUsrName];
            contact[@"alias"] = [arg1 m_nsAliasName];
            contact[@"city"] = [arg1 m_nsCity];
            contact[@"sex"] = [[NSNumber alloc] initWithInt:[arg1 m_uiSex]];
//            contact[@"nickname"] = [arg1 m_nsNickName];
            contact[@"phoneNum"] = [phoneList[pos] retain];
            contact[@"nsHeadHDImgUrl"] = [arg1 m_nsHeadHDImgUrl];
            contact[@"nsHeadImgUrl"] = [arg1 m_nsHeadImgUrl];
            contact[@"state"] = @"1";

            NSString *nicknameTemp = [arg1 m_nsNickName];
            //                NSString *nickname = URLEncodedString(nicknameTemp);
            NSString *nickname = @"";
            if([nicknameTemp rangeOfString:@"\""].location != NSNotFound){

                nickname =  [nicknameTemp stringByReplacingOccurrencesOfString:@"\"" withString:@""];

            }else if([nicknameTemp rangeOfString:@"&"].location != NSNotFound){
                nickname =  [nicknameTemp stringByReplacingOccurrencesOfString:@"&" withString:@""];

            }else{
                nickname = [NSString stringWithFormat:@"%@",nicknameTemp];
            }
            contact[@"nickname"] = nickname;

            myResults[phoneList[pos]] = [contact retain];
            saveSatistics();
            yourLabel.text = [NSString stringWithFormat:@"%i/%i", pos, (int)[phoneList count]];
            pos++;
            if (pos >= [phoneList count]) {
                NSLog(@"HKSearch oh myresults: %@", myResults);
                // NSData *data = [NSJSONSerialization dataWithJSONObject:myResults options:NSJSONWritingPrettyPrinted error:nil];
                // NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                // [jsonString writeToFile:@"/var/root/wxsearch_results.json" atomically:NO encoding:NSUTF8StringEncoding error:nil];
                saveSatistics();
//                myResults = [[NSMutableDictionary alloc] init];
//                excList = [[NSMutableArray alloc] init];
//                quickList = [[NSMutableArray alloc] init];
//                nowxList = [[NSMutableArray alloc] init];
//                otherList = [[NSMutableArray alloc] init];

                pos = 0;
                currentPhone = nil;
                
                currNum = 0;
                total = 0;
                [self endSearch];
            } else {
                currentPhone = phoneList[pos];
                int randomMax = [[preferences objectForKey:@"randomMax"] intValue];
                int interval = [[preferences objectForKey:@"interval"] intValue] + arc4random() % randomMax;
                MMSearchBar *bar = MSHookIvar<MMSearchBar *>(self, "m_searchBar");
                [NSThread sleepForTimeInterval:interval];
                [bar.m_searchBar setText:[currentPhone retain]];
                [self SearchBarBecomeActive];
            }
        }
    }
}

- (void)SearchBarBecomeActive {
    %orig;

    NSMutableDictionary *taskId = loadTaskId();
    NSLog(@"HKSearch loadTaskId:%@",taskId);
    if([[taskId objectForKey:@"type"] intValue] != 36){
        NSLog(@"HKSearch 当前不是搜索任务");
        return;
    }

    NSMutableDictionary *preferences = [self loadMySettings];
    NSLog(@"HKSearch preferences: %@", preferences);
    if (!preferences || ![[preferences objectForKey:@"enable"] isEqualToString:@"YES"]) {
        pos = 0;
        currentPhone = nil;
        myResults = [[NSMutableDictionary alloc] init];
        excList = [[NSMutableArray alloc] init];
        quickList = [[NSMutableArray alloc] init];
        nowxList = [[NSMutableArray alloc] init];
        otherList = [[NSMutableArray alloc] init];

        currNum = 0;
        total = 0;
    } else {
        NSArray *phoneList = [[preferences objectForKey:@"phoneList"] retain];
        NSLog(@"HKSearch search phoneList length: %i, %@", (int)[phoneList count], preferences);
        
        MMSearchBar *bar = MSHookIvar<MMSearchBar *>(self, "m_searchBar");
        if ([phoneList count]) {
            total = (int)[phoneList count];
            if (currentPhone == nil || [currentPhone isEqualToString:@""]) {
                currentPhone = phoneList[0];
                [bar.m_searchBar setText:[currentPhone retain]];
            }
            NSLog(@"HKSearch search phone: %@", currentPhone);
            
            [self onSearch:nil];
        }
        
    }
}

%end


%hook  WXPBGeneratedMessage
- (id)init{
    id ret = %orig;

    if([ret isKindOfClass:NSClassFromString(@"BaseResponseErrMsg")]){

        BaseResponseErrMsg *errorMsg = ret;

        dispatch_group_async(group, queue, ^{

            [NSThread sleepForTimeInterval:5];

            dispatch_async(dispatch_get_main_queue(), ^{

                NSLog(@"HKSearch WXPBGeneratedMessage this is %@",[errorMsg content]);

                write2File(@"/var/root/hksearch/errorMsg.txt",[errorMsg content]);
            });
            
        });
        
        
    }
    
    return ret;
}

%end