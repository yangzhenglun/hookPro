//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "NSObject.h"

@class MDBaseMessage, MDMixItem, NSString, NSURL, UITableViewCell;

@protocol MDChatCellDelegate <NSObject>
- (void)willStartDownloadThumbNail:(MDBaseMessage *)arg1;
- (void)didSelectedCellRevoke:(MDBaseMessage *)arg1;
- (void)didHandleResendMsg:(MDBaseMessage *)arg1;
- (void)didHandleRelay:(MDBaseMessage *)arg1;
- (void)didHandleVoiceToText:(MDBaseMessage *)arg1;
- (void)didSelectedTextITMS:(NSURL *)arg1;
- (void)didSelectedTextUrl:(NSURL *)arg1;
- (void)didSelectedTextPhoneNumber:(NSString *)arg1;
- (void)didLongPressCell:(UITableViewCell *)arg1 message:(MDBaseMessage *)arg2 clickPoint:(struct CGPoint)arg3;
- (void)didSelectedCellDelete:(UITableViewCell *)arg1;
- (void)didSelectedChatTail:(UITableViewCell *)arg1 message:(MDBaseMessage *)arg2;
- (void)didSelectedChatVideo:(UITableViewCell *)arg1 message:(MDBaseMessage *)arg2;
- (void)didSelectedChatAudio:(UITableViewCell *)arg1 mixItem:(MDMixItem *)arg2;
- (void)didSelectedChatLocation:(UITableViewCell *)arg1 message:(MDBaseMessage *)arg2;
- (void)didSelectedChatImage:(UITableViewCell *)arg1 message:(MDBaseMessage *)arg2;
- (void)didSelectedChatEmotion:(UITableViewCell *)arg1 message:(MDBaseMessage *)arg2 eid:(NSString *)arg3 eName:(NSString *)arg4;
- (void)didSelectedChatText:(UITableViewCell *)arg1 message:(MDBaseMessage *)arg2;
- (void)didSelectedHeadImage:(UITableViewCell *)arg1 message:(MDBaseMessage *)arg2;

@optional
- (double)playingAudioProgressForMessage:(MDBaseMessage *)arg1;
- (void)shouldDownloadChatAudioForMessage:(MDBaseMessage *)arg1;
- (_Bool)loadingAudioIsUserLastTappedMessage:(MDBaseMessage *)arg1;
- (void)didHandleForbid:(MDBaseMessage *)arg1;
- (void)didHandleReport:(MDBaseMessage *)arg1;
- (void)didHandleSpecial:(MDBaseMessage *)arg1;
- (void)didAimAtOne:(NSString *)arg1 momoID:(NSString *)arg2;
- (void)didSelectedCellGift:(MDBaseMessage *)arg1;
@end

