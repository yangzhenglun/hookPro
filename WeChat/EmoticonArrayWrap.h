//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "MMObject.h"

@class NSMutableArray, NSObject, NSString;

@interface EmoticonArrayWrap : MMObject
{
    NSMutableArray *m_array;
    long long m_currentPageNum;
    NSString *m_pid;
    long long m_totalPageNum;
    NSObject *_m_userInfo;
}

@property(retain, nonatomic) NSObject *m_userInfo; // @synthesize m_userInfo=_m_userInfo;
@property(nonatomic) long long m_totalPageNum; // @synthesize m_totalPageNum;
@property(retain, nonatomic) NSString *m_pid; // @synthesize m_pid;
@property(nonatomic) long long m_currentPageNum; // @synthesize m_currentPageNum;
@property(retain, nonatomic) NSMutableArray *m_array; // @synthesize m_array;
- (void).cxx_destruct;
- (void)dealloc;

@end
