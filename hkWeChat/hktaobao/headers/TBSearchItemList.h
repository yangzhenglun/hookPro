// #import <UIKIT/UIKIT.h>
#import <Foundation/Foundation.h>


@interface TBSearchItemList 
{
    _Bool _nextpageEmpty;	// 8 = 0x8
    unsigned long long _currentPage;	// 16 = 0x10
    long long _totalCount;	// 24 = 0x18
    unsigned long long _pageSize;	// 32 = 0x20
    NSMutableArray *_realItemList;	// 40 = 0x28
}

+ (id)array;
@property(retain, nonatomic) NSMutableArray *realItemList; // @synthesize realItemList=_realItemList;
@property(nonatomic) _Bool nextpageEmpty; // @synthesize nextpageEmpty=_nextpageEmpty;
@property(nonatomic) unsigned long long pageSize; // @synthesize pageSize=_pageSize;
@property(nonatomic) long long totalCount; // @synthesize totalCount=_totalCount;
@property(nonatomic) unsigned long long currentPage; // @synthesize currentPage=_currentPage;

// - (unsigned long long)countByEnumeratingWithState:(CDStruct_70511ce9 *)arg1 objects:(id *)arg2 count:(unsigned long long)arg3;
- (void)removeObjectAtIndex:(unsigned long long)arg1;
- (void)insertObject:(id)arg1 atIndex:(unsigned long long)arg2;
- (void)removeObject:(id)arg1;
- (void)removeAllObjects;
- (void)addObjectsFromArray:(id)arg1;
- (void)addObject:(id)arg1;
- (id)objectAtIndex:(unsigned long long)arg1;
- (unsigned long long)count;
- (_Bool)hasMore;
- (void)reset;
- (id)init;

@end