//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "NSObject.h"

@interface _ASCollectionPendingState : NSObject
{
    id <ASCollectionDelegate> _delegate;
    id <ASCollectionDataSource> _dataSource;
}

@property(nonatomic) __weak id <ASCollectionDataSource> dataSource; // @synthesize dataSource=_dataSource;
@property(nonatomic) __weak id <ASCollectionDelegate> delegate; // @synthesize delegate=_delegate;
- (void).cxx_destruct;

@end

