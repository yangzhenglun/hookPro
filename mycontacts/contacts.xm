
// Logos by Dustin Howett
// See http://iphonedevwiki.net/index.php/Logos

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

#import "contacts.h"
#import "substrate.h"
static dispatch_group_t group = dispatch_group_create();
static dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);


static id membersViewController = nil;

%hook ABMembersViewController

- (id)initWithModel:(id)arg1 {
    if ((self = %orig))
        
        membersViewController = self;
        
        return self;
}

%new(v@:)
- (void)deleteContact {
    NSMutableDictionary *config = [[NSMutableDictionary alloc] initWithContentsOfFile:booksPath];
//    NSLog(@"HKContacts deleteContact:%@", config);
    NSLog(@"HKContacts %@", [config[@"enable"] isEqualToString:@"YES"] ? @"YES": @"NO");
//    if ([config[@"enable"] isEqualToString:@"YES"] && [config[@"deleteOrAdd"] isEqualToString:@"delete"]) {
    if ([config[@"enable"] isEqualToString:@"YES"]) {
        
        ABModel *model = [self model];
        NSMutableArray *myRecords = MSHookIvar<NSMutableArray *>(model, "_cachedModelRecords");

        while([myRecords count]){

            NSLog(@"HKContacts deleteContact:myRecords:%@ ",myRecords);

            ABAddressBookRef ab = [model addressBook];

            if ([myRecords count]) {

                for (int i=0; i < [myRecords count]; i++) {
                    NSLog(@"HKContacts delete person pos %i ",i);

                    ABRecordRef person = [model displayedMemberAtIndex:i];
                    if (person) {

                        ABAddressBookRemoveRecord(ab, person, NULL);

                    } else {
                        continue;
                    }
                }
            }
            
            ABAddressBookSave(ab, NULL);
            [membersViewController personWasDeleted];
            [self refreshEverythingNow];

            myRecords = MSHookIvar<NSMutableArray *>(model, "_cachedModelRecords");
        }
    }
}

- (void)viewDidAppear:(BOOL)arg1 {
    %orig;

    //异步延时点击进入聊天
    dispatch_group_async(group, queue, ^{

        [NSThread sleepForTimeInterval:5];

        dispatch_async(dispatch_get_main_queue(), ^{

            while(true){
                [self deleteContact];

                [self refreshEverythingNow];

                ABModel *model = [self model];
                NSMutableArray *myRecords = MSHookIvar<NSMutableArray *>(model, "_cachedModelRecords");

                if ([myRecords count] == 0){
                    break;
                }
            }
            
            NSLog(@"HKContacts 删除完毕!");
            
            [self addMyContacts];
            [self refreshEverythingNow];
            
        });
        
    });

}

%new(v@:)
- (void)addMyContacts {
    NSMutableDictionary *config = [[NSMutableDictionary alloc] initWithContentsOfFile:booksPath];

//    if ([config[@"enable"] isEqualToString:@"YES"] && [config[@"deleteOrAdd"] isEqualToString:@"add"]) {
    if ([config[@"enable"] isEqualToString:@"YES"]) {
        NSLog(@"HKContacts addressBooks: %@", config[@"addressBooks"]);

        for (id key in config[@"addressBooks"]) {
            NSMutableDictionary *abook = config[@"addressBooks"][key];
            CNMutableContact *contact = [[NSClassFromString(@"CNMutableContact") alloc] init];
            NSLog(@"HKContacts abok: %@", key);
            CNPhoneNumber *phone = [[NSClassFromString(@"CNPhoneNumber") alloc] initWithStringValue:key];
            CNLabeledValue *label = [NSClassFromString(@"CNLabeledValue") labeledValueWithLabel:@"_$!<Mobile>!$_" value:phone];
            contact.phoneNumbers = @[label];
            contact.familyName = abook[@"familyName"];
            contact.givenName = abook[@"givenName"];
            contact.nickname = abook[@"nickname"];
            NSLog(@"HKContacts add contacts: %@", contact);

            [contact saveContactInAddressBook:[[self model] addressBook]];
            [contact saveContact];
        }
    }
}

%end

%hook ABMembersDataSource

//%new(c@:@@)
//
//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSMutableDictionary *config = [[NSMutableDictionary alloc] initWithContentsOfFile:booksPath];
//    if (config[@"enable"]) {
//        NSLog (@"HKContacts Enabled %@", config);
////        [self deleteContact];
//        if ([config[@"deleteOrAdd"] isEqualToString:@"delete"]) {
//            NSLog(@"HKContacts enable delete: %i", globalRow);
//            if ([[tableView _rowData] globalRowForRowAtIndexPath:indexPath] == 0  && [[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.mobilephone"]) {
//                NSLog(@"HKContacts oh not enable editing");
//                return NO;
//            }
//            
//            return YES;
//        }
//    } else {
//        return NO;
//    }
//}

//%new(v@:@i@)
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"HKContacts now commit editing style: %i", globalRow);
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        globalRow = (NSInteger)[[tableView _rowData] globalRowForRowAtIndexPath:indexPath];
//        if ([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.mobilephone"]) {
//            NSLog(@"HKContacts: can deleted");
////            globalRow--;
//            
//        }
//      
//    }
//}


%end // end hook