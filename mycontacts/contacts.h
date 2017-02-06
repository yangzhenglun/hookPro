//
//  contacts.h
//  contacts
//
//  Created by summer1988 on 2016/9/3.
//
//

#ifndef contacts_h
#define contacts_h

//#define HBLogDebug NSLog
//#define HBLogError NSLog

#define booksPath @"/var/root/abooks.plist"

#import <UIKit/UITableViewCell.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
//#import <Contacts/Contacts.h>
//#import <ContactsUI/ContactsUI.h>

@interface CNLabeledValue

+ (void*)addressBook;
+ (id)allLabels;
+ (id)defaultLabels;
+ (id)builtinLabelsForProperty:(id)arg1;
+ (id)labeledValueWithMultiValueIdentifier:(int)arg1 label:(id)arg2 value:(id)arg3;
+ (void)deleteCustomLabel:(id)arg1;
+ (id)allCustomLabels;
+ (id)labeledValueWithLabel:(id)arg1 value:(id)arg2;

- (id)initWithLabel:(id)arg1 value:(id)arg2;
- (id)label;
- (id)value;
- (id)identifier;
- (BOOL)isEqual:(id)arg1;
- (id)labeledValueBySettingValue:(id)arg1;
- (BOOL)isEqualToLabelledValue:(id)arg1 includeIdentifiers:(BOOL)arg2;
- (id)initWithMultiValueIdentifier:(int)arg1 label:(id)arg2 value:(id)arg3;
- (BOOL)isEqualToLabelledValue:(id)arg1;
- (id)labeledValueBySettingLabel:(id)arg1 value:(id)arg2;

@end

@interface CNPhoneNumber

@property(nonatomic, retain)  NSString * stringValue;
@property(nonatomic, retain)  NSString * countryCode;
@property(nonatomic, retain)  NSString * formattedStringValue;
@property(nonatomic, retain)  NSString * normalizedStringValue;

+ (id)phoneNumberWithStringValue:(id)arg1;

- (id)stringValue;
- (BOOL)isEqual:(id)arg1;
- (id)initWithStringValue:(id)arg1;

@end

@interface CNContact

@property(nonatomic, retain) NSString * givenName;
@property(nonatomic, retain) NSString * familyName;
@property(nonatomic, retain) NSString * nameSuffix;
@property(nonatomic, retain) NSString * nickname;
@property(nonatomic, retain) NSArray *phoneNumbers;
@property void* source;
@property void* addressBook;

@end

@interface CNMutableContact : CNContact

- (BOOL)saveContact;
- (BOOL)saveContactInAddressBook:(const void *)arg1;
- (BOOL)deleteContact;

@end

@interface CNMutablePhoneNumber : CNPhoneNumber  {
}

- (void)setStringValue:(id)arg1;

@end


@interface ABModel : NSObject
{
    NSMutableArray *_cachedModelRecords;
}
- (ABRecordRef)displayedMemberAtIndex:(NSInteger)index;
- (ABAddressBookRef)addressBook;

@end

@interface ABMembersDataSource : NSObject <UITableViewDataSource>

- (ABModel *)model;
- (void)deleteContact;

@end

@interface ABMembersController : NSObject

@property (nonatomic,readonly) UITableView * currentTableView;
- (UITableView *)tableView;

@end

@interface ABMembersViewController : UIViewController
- (void)deleteContact;
- (void)addMyContacts;
- (void)viewDidAppear:(BOOL)arg1;
- (ABModel *)model;
- (void)refreshEverythingNow;
- (id)initWithModel:(ABModel *)model;
- (ABMembersController *)membersController;
- (void)personWasDeleted;
- (void)updateEditButton;
- (void)viewDidLoad;
-(id)tableView;

@end


#endif /* contacts_h */
