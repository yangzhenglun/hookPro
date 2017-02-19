//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "NSObject.h"

@class AddressSearchAPI, EasyBuyAPI, JDBaseAPI, JDPostalAddressModel, JDRegionModel, JDShippingAddressModel, NSArray, NSMutableArray, NSNumber, NSString, OrderAddressAPI;

@interface JDContactViewModel : NSObject
{
    _Bool _editMode;
    _Bool _enabledRestoreScene;
    _Bool _active;
    _Bool _defaultAddressFlag;
    _Bool _enabledEasyBuyConfigServices;
    _Bool _selectedPayOnline;
    _Bool _selectedPickSite;
    _Bool _selectedBookingDirect;
    _Bool _enabledValidRegionService;
    _Bool _usedServerAddress;
    _Bool _modifyEasyBuyFullAddress;
    CDUnknownBlockType _didBecomeActive;
    CDUnknownBlockType _didBecomeInActive;
    CDUnknownBlockType _needReloadUISingal;
    unsigned long long _type;
    NSString *_inputName;
    NSString *_inputMobile;
    NSString *_inputRegion;
    NSString *_inputStreet;
    long long _coordinateType;
    double _longitude;
    double _latitude;
    JDRegionModel *_province;
    JDRegionModel *_city;
    JDRegionModel *_county;
    JDRegionModel *_town;
    NSNumber *_pickSiteID;
    NSString *_pickSiteName;
    JDShippingAddressModel *_shouldEditAddressModel;
    JDBaseAPI *_activeAPI;
    JDBaseAPI *_deleteAddressAPI;
    JDBaseAPI *_saveAddressAPI;
    OrderAddressAPI *_orderAddressAPI;
    NSArray *_regionIDArray;
    EasyBuyAPI *_easyBuyAPI;
    NSMutableArray *_regionArray;
    JDRegionModel *_tmp_province;
    JDRegionModel *_tmp_city;
    JDRegionModel *_tmp_county;
    JDRegionModel *_tmp_town;
    AddressSearchAPI *_addressSearchAPI;
    JDPostalAddressModel *_serverAddressModel;
    NSArray *_sceneSnapshootArray;
}

@property(retain, nonatomic) NSArray *sceneSnapshootArray; // @synthesize sceneSnapshootArray=_sceneSnapshootArray;
@property(retain, nonatomic) JDPostalAddressModel *serverAddressModel; // @synthesize serverAddressModel=_serverAddressModel;
@property(retain, nonatomic) AddressSearchAPI *addressSearchAPI; // @synthesize addressSearchAPI=_addressSearchAPI;
@property(retain, nonatomic) JDRegionModel *tmp_town; // @synthesize tmp_town=_tmp_town;
@property(retain, nonatomic) JDRegionModel *tmp_county; // @synthesize tmp_county=_tmp_county;
@property(retain, nonatomic) JDRegionModel *tmp_city; // @synthesize tmp_city=_tmp_city;
@property(retain, nonatomic) JDRegionModel *tmp_province; // @synthesize tmp_province=_tmp_province;
@property(retain, nonatomic) NSMutableArray *regionArray; // @synthesize regionArray=_regionArray;
@property(retain, nonatomic) EasyBuyAPI *easyBuyAPI; // @synthesize easyBuyAPI=_easyBuyAPI;
@property(retain, nonatomic) NSArray *regionIDArray; // @synthesize regionIDArray=_regionIDArray;
@property(retain, nonatomic) OrderAddressAPI *orderAddressAPI; // @synthesize orderAddressAPI=_orderAddressAPI;
@property(retain, nonatomic) JDBaseAPI *saveAddressAPI; // @synthesize saveAddressAPI=_saveAddressAPI;
@property(retain, nonatomic) JDBaseAPI *deleteAddressAPI; // @synthesize deleteAddressAPI=_deleteAddressAPI;
@property(retain, nonatomic) JDBaseAPI *activeAPI; // @synthesize activeAPI=_activeAPI;
@property(retain, nonatomic) JDShippingAddressModel *shouldEditAddressModel; // @synthesize shouldEditAddressModel=_shouldEditAddressModel;
@property(nonatomic, getter=isModifyEasyBuyFullAddress) _Bool modifyEasyBuyFullAddress; // @synthesize modifyEasyBuyFullAddress=_modifyEasyBuyFullAddress;
@property(nonatomic, getter=isUsedServerAddress) _Bool usedServerAddress; // @synthesize usedServerAddress=_usedServerAddress;
@property(nonatomic, getter=isEnabledValidRegionService) _Bool enabledValidRegionService; // @synthesize enabledValidRegionService=_enabledValidRegionService;
@property(copy, nonatomic) NSString *pickSiteName; // @synthesize pickSiteName=_pickSiteName;
@property(retain, nonatomic) NSNumber *pickSiteID; // @synthesize pickSiteID=_pickSiteID;
@property(nonatomic, getter=isSelectedBookingDirect) _Bool selectedBookingDirect; // @synthesize selectedBookingDirect=_selectedBookingDirect;
@property(nonatomic, getter=isSelectedPickSite) _Bool selectedPickSite; // @synthesize selectedPickSite=_selectedPickSite;
@property(nonatomic, getter=isSelectedPayOnline) _Bool selectedPayOnline; // @synthesize selectedPayOnline=_selectedPayOnline;
@property(nonatomic, getter=isEnabledEasyBuyConfigServices) _Bool enabledEasyBuyConfigServices; // @synthesize enabledEasyBuyConfigServices=_enabledEasyBuyConfigServices;
@property(retain, nonatomic) JDRegionModel *town; // @synthesize town=_town;
@property(retain, nonatomic) JDRegionModel *county; // @synthesize county=_county;
@property(retain, nonatomic) JDRegionModel *city; // @synthesize city=_city;
@property(retain, nonatomic) JDRegionModel *province; // @synthesize province=_province;
@property(nonatomic, getter=isDefaultAddressFlag) _Bool defaultAddressFlag; // @synthesize defaultAddressFlag=_defaultAddressFlag;
@property(nonatomic) double latitude; // @synthesize latitude=_latitude;
@property(nonatomic) double longitude; // @synthesize longitude=_longitude;
@property(nonatomic) long long coordinateType; // @synthesize coordinateType=_coordinateType;
@property(copy, nonatomic) NSString *inputStreet; // @synthesize inputStreet=_inputStreet;
@property(copy, nonatomic) NSString *inputRegion; // @synthesize inputRegion=_inputRegion;
@property(copy, nonatomic) NSString *inputMobile; // @synthesize inputMobile=_inputMobile;
@property(copy, nonatomic) NSString *inputName; // @synthesize inputName=_inputName;
@property(readonly, nonatomic) unsigned long long type; // @synthesize type=_type;
@property(copy, nonatomic) CDUnknownBlockType needReloadUISingal; // @synthesize needReloadUISingal=_needReloadUISingal;
@property(copy, nonatomic) CDUnknownBlockType didBecomeInActive; // @synthesize didBecomeInActive=_didBecomeInActive;
@property(copy, nonatomic) CDUnknownBlockType didBecomeActive; // @synthesize didBecomeActive=_didBecomeActive;
@property(nonatomic, getter=isActive) _Bool active; // @synthesize active=_active;
@property(nonatomic, getter=isEnabledRestoreScene) _Bool enabledRestoreScene; // @synthesize enabledRestoreScene=_enabledRestoreScene;
- (void).cxx_destruct;
- (void)stopFetchResult;
- (void)parseEasyBuySaveAddressAPIWithResult:(id)arg1 completionBlock:(CDUnknownBlockType)arg2;
- (void)parseSettlementSaveAddressAPIWithResult:(id)arg1 completionBlock:(CDUnknownBlockType)arg2;
- (void)updateAddressModelWithServerAddress;
- (void)updateAddressModelWithEasyBuyConfig;
- (void)updateAddressModelWithBasicInfoConfig;
- (id)removeSpecialStrings:(id)arg1 withOriginString:(id)arg2;
- (id)validateInputConfigInfo;
- (void)saveAddressWithCompletionBlock:(CDUnknownBlockType)arg1;
- (void)deleteAddressWithCompletionBlock:(CDUnknownBlockType)arg1;
- (void)setJumpOrderType:(unsigned long long)arg1 withCompletionBlock:(CDUnknownBlockType)arg2;
- (void)getJumpOrderTypeWithCompletionBlock:(CDUnknownBlockType)arg1;
- (void)updateEasyBuyConfig;
@property(readonly, nonatomic, getter=isDefaultEasyBuyFlag) _Bool defaultEasyBuyFlag;
- (id)regionAddressInAddressViewTab:(long long)arg1 selectedRow:(long long)arg2;
- (long long)numberOfRowsInAddressViewTab:(long long)arg1;
- (void)updateRegionIDArrayWithUserSeletecdRegion;
- (void)setSelectedRegion;
- (void)updateRegionConfigWithTab:(long long)arg1 selectedRow:(long long)arg2;
- (void)getRegionAddressWithAddressViewTab:(long long)arg1 selectedRow:(long long)arg2 completionBlock:(CDUnknownBlockType)arg3;
- (void)getRegionAddressWithTab:(long long)arg1 selectedRow:(long long)arg2 completionBlock:(CDUnknownBlockType)arg3;
- (void)getAddressSuggestionWithKeyWord:(id)arg1 completionBlock:(CDUnknownBlockType)arg2;
@property(readonly, nonatomic) NSArray *regionIDSnapShootArray;
@property(readonly, nonatomic) NSString *helpURLString;
- (id)region;
- (void)updateBaseInfoConfig;
@property(readonly, nonatomic, getter=isEditMode) _Bool editMode; // @synthesize editMode=_editMode;
@property(readonly, nonatomic) JDShippingAddressModel *editAddressModel;
- (id)initWithContactType:(unsigned long long)arg1 addressModel:(id)arg2;

@end
