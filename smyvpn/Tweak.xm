#import <objc/runtime.h>
#import <substrate.h>
#import <SpringBoard/SpringBoard.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <Foundation/Foundation.h>

static NSString *m_preferences_plist = @"/var/mobile/Library/Preferences/com.summer1988-vpn.plist";  //plist路径

@interface VPNConnectionStore
@end
@interface VPNConnection
@end

@interface PSSpecifier
- (void)setProperties:(id)arg1;
- (id)propertyForKey:(id)arg1;
- (void)setObject:(id)arg1 forKeyedSubscript:(id)arg2;

@end

%hook PSSpecifier

- (void)setObject:(id)arg1 forKeyedSubscript:(id)arg2 {
	NSLog(@"MYHOOK setobj: %@, %@", arg1, arg2);
	%orig;
}
// - (void)setProperties:(id)arg1 {
// 	NSLog(@"MHOOK setProperties: %@", arg1);
// 	%orig;
// }
// - (id)propertyForKey:(id)arg1 {
// 	NSLog(@"MYHOOK set ProepFk: %@", arg1);
// 	return %orig;
// }
%end
@interface NEConfiguration

@end

@interface VPNSetupListController
-(void)setPassword:(id)arg1 forSpecifier:(id)arg2 ;
-(void)setUsername:(id)arg1 forSpecifier:(id)arg2 ;
-(void)setServer:(id)arg1 forSpecifier:(id)arg2 ;
-(void)setDisplayName:(id)arg1 forSpecifier:(id)arg2 ;
-(void)setVPNType:(CFStringRef)arg1 forSpecifier:(id)arg2 ;
-(void)setSendAllTraffic:(id)arg1 forSpecifier:(id)arg2 ;
-(void)setPPTPEncryptionLevel:(id)arg1 forSpecifier:(id)arg2 ;
- (void)saveConfigurationSettings;
- (void)_saveConfigurationSettings;
- (id)specifiers;
- (id)loadSpecifiersFromPlistName:(id)arg1 target:(id)arg2 ;
-(BOOL)deleteConfiguration:(id)arg1 ;
-(void)saveButtonClicked:(id)arg1 ;
-(void)deleteVPNConfiguration:(id)arg1 ;
-(void)saveButtonTapped:(id)arg1 ;
-(id)remoteIPForSpecifier:(id)arg1 ;

@end



%hook VPNSetupListController

-(id)remoteIPForSpecifier:(id)arg1  {
	NSLog(@"MYHOOK remoat IP");
	return %orig;
}

- (id)specifiers {
	NSLog(@"MYHOOK gggsper");
	return %orig;
	
}
-(void)saveButtonClicked:(id)arg1  {
	NSLog(@"MYHOOK savebutton click: %@", arg1);
	%orig;
}

-(void)saveButtonTapped:(id)arg1 {
	NSLog(@"MYHOOK savebutton typed: %@, %@, %@", arg1, [arg1 class], MSHookIvar<PSSpecifier *>(self, "_updateButton"));
	%orig;
}

-(BOOL)deleteConfiguration:(id)arg1  {
	BOOL res = %orig;
	NSLog(@"MYHOOK deletec: %@", arg1);
	return res;
}
-(void)deleteVPNConfiguration:(id)arg1  {
	NSLog(@"MYHOOK delete VPNC: %@", arg1);
	%orig;
}
- (id)loadSpecifiersFromPlistName:(id)arg1 target:(id)arg2 {
	NSDictionary* info = [NSDictionary dictionaryWithContentsOfFile:m_preferences_plist];
	if (![info[@"enable"] boolValue]) {
		return %orig;
	}
	// NSMutableArray* allowsList = info[@"allowsList"];
	// id res = %orig;
	NSDictionary* config = info[@"config"];
	NSBundle* VPNPreferences = [NSBundle bundleWithPath:@"/System/Library/PreferenceBundles/VPNPreferences.bundle"];

		// VPNSetupListController* vpnSetup = arg2;//[[NSClassFromString(@"VPNSetupListController") alloc] init];
		NSString *username = config[@"username"];
		NSString *password = config[@"password"];
		NSString *server = config[@"server"];
		NSString *type = config[@"type"];
		NSString *name = config[@"name"];
		NSString *changed = config[@"ch"];
		NSLog(@"MYHOOK chage: %@", config);
		[arg2 setDisplayName:name forSpecifier:nil];
		[arg2 setVPNType:(__bridge CFStringRef)type forSpecifier:nil];
		[arg2 setServer:server forSpecifier:nil];
		[arg2 setUsername:username forSpecifier:nil];
		[arg2 setPassword:password forSpecifier:nil];
		[arg2 setSendAllTraffic:[NSNumber numberWithBool:YES] forSpecifier:nil];
		[arg2 setPPTPEncryptionLevel:@1 forSpecifier:nil];
		NSLog(@"MYHOOK %d", MSHookIvar<BOOL>(self, "_dirty"));
		if (MSHookIvar<BOOL>(self, "_dirty") == YES) {
			Ivar ivar = class_getInstanceVariable([self class], "_updateButton");
			NSString *a = [[VPNPreferences localizedStringForKey:@"UPDATE_VPN" value:@"" table:@"MobileVPN"] retain];
			PSSpecifier *p = [[NSClassFromString(@"PSSpecifier") preferenceSpecifierNamed:a target:arg2 set:0x0 get:0x0 detail:0x0 cell:0xd edit:0x0] retain];
			[p setButtonAction:@selector(saveButtonTapped:)];
			object_setIvar(self, ivar, (id)p);
			[arg2 saveButtonTapped:MSHookIvar<PSSpecifier *>(self, "_updateButton")];
			Ivar m = class_getInstanceVariable([self class], "_dirty");
			object_setIvar(self, m, (id)NO);
		}
	[VPNPreferences release];
	NSLog(@"MYHOOK %@, %@", arg1, arg2);
	id res = %orig;
	return res;
}
%end

@interface PSConfirmationSpecifier

-(void)setupWithDictionary:(id)arg1;

@end

%hook PSConfirmationSpecifier
-(void)setupWithDictionary:(id)arg1 {
	NSLog(@"MYHOOK %@", arg1);
	%orig;
}
%end

//NSString* curAppbundleID=[[NSBundle mainBundle] bundleIdentifier];
@interface SBApplication:NSObject{

}
-(id)bundleIdentifier;
@end


@interface VPNBundleController : NSObject {

	char _networkSpinnerVisible;
	char _rootMenuItem;
	char _toggleSwitchInRootMenu;
	char _registered;
	/*VPNConnectionStore* _connectionStore;
	NSNumber* _lastServiceCount;
	PSSpecifier* _passwordSetupSpecifier;
	PSSpecifier* _vpnSpecifier;
	PSSpecifier* _linkVPNSpecifier;
	PSConfirmationSpecifier* _toggleVPNSpecifier;*/

}

/*@property (retain) VPNConnectionStore * connectionStore;                              //@synthesize connectionStore=_connectionStore - In the implementation block
@property (retain) NSNumber * lastServiceCount;                                       //@synthesize lastServiceCount=_lastServiceCount - In the implementation block
@property (retain) PSSpecifier * passwordSetupSpecifier;                              //@synthesize passwordSetupSpecifier=_passwordSetupSpecifier - In the implementation block
@property (retain) PSSpecifier * vpnSpecifier;                                        //@synthesize vpnSpecifier=_vpnSpecifier - In the implementation block
@property (retain) PSSpecifier * linkVPNSpecifier;                                    //@synthesize linkVPNSpecifier=_linkVPNSpecifier - In the implementation block
@property (retain) PSConfirmationSpecifier * toggleVPNSpecifier; */                     //@synthesize toggleVPNSpecifier=_toggleVPNSpecifier - In the implementation block
@property (getter=isNetworkSpinnerVisible) char networkSpinnerVisible;                //@synthesize networkSpinnerVisible=_networkSpinnerVisible - In the implementation block
@property (getter=isRootMenuItem) char rootMenuItem;                                  //@synthesize rootMenuItem=_rootMenuItem - In the implementation block
@property (getter=isToggleSwitchInRootMenu) char toggleSwitchInRootMenu;              //@synthesize toggleSwitchInRootMenu=_toggleSwitchInRootMenu - In the implementation block
@property (getter=isRegistered) char registered;                                      //@synthesize registered=_registered - In the implementation block
-(id)initWithParentListController:(id)Meh;
+(char)networkingIsDisabled;
+(void)disableAirplaneMode;
-(char)isRegistered;
-(void)setRegistered:(char)arg1 ;
-(void)dealloc;
-(char)isNetworkSpinnerVisible;
-(void)setNetworkSpinnerVisible:(char)arg1 ;
-(unsigned)getStatusAndUpdateNetworkSpinnerVisibility;
//-(PSSpecifier *)vpnSpecifier;
//-(PSConfirmationSpecifier *)toggleVPNSpecifier;
-(void)vpnStatusChanged:(id)arg1 ;
-(void)setVPNActive:(BOOL)arg1 ;
-(void)_setVPNActive:(BOOL)arg1 ;
-(void)setVPNActive:(id)arg1 forSpecifier:(id)arg2 ;
-(id)vpnActiveForSpecifier:(id)arg1 ;
//-(void)setToggleVPNSpecifier:(PSConfirmationSpecifier *)arg1 ;
-(void)confirmAirplaneModeDisable:(id)arg1 ;
-(void)cancelAirplaneModeDisable:(id)arg1 ;
//-(PSSpecifier *)linkVPNSpecifier;
//-(void)setLinkVPNSpecifier:(PSSpecifier *)arg1 ;
-(char)isRootMenuItem;
-(void)setLastServiceCount:(NSNumber *)arg1 ;
-(NSNumber *)lastServiceCount;
-(void)setToggleSwitchInRootMenu:(char)arg1 ;
-(char)isToggleSwitchInRootMenu;
-(void)vpnConfigurationChanged:(id)arg1 ;
-(void)setRootMenuItem:(char)arg1 ;
-(void)updateVPNSwitchStatus;
-(id)statusForSpecifier:(id)arg1 ;
-(void)unload;
-(id)specifiersWithSpecifier:(id)arg1 ;
-(id)initWithParentListController:(id)arg1 properties:(id)arg2 ;
@end



@interface VPNController : NSObject {

	id _statusSpecifier;
	id _switchSpecifier;
	id _vpnListSeparatorGroupSpecifier;
	id _otherVPNSpecifier;
	id _linkVPNSpecifier;
	id _vpnSpecifier;
	NSArray* _cancelSpecifiers;
	NSString* _activeVPNServiceID;
	id _activeVPNSpecifier;
	id _alert;
	unsigned long long _vpnServiceCount;

}
+(id)sharedInstance;
-(void)dealloc;
-(id)init;
-(id)startPersonalConnection:(id)arg1 ;
-(id)startEnterpriseConnection:(id)arg1 ;
-(void)activateVPN:(id)arg1 ;
-(void)updateVPNConfigurationsList;
-(id)specifiers;
-(void)connect;
-(void)formSheetViewWillDisappear;
-(void)willBecomeActive;
-(void)showStatus:(id)arg1 ;
-(void)activateVPN:(id)arg1 ;
-(id)serverForConnection:(id)arg1 ;
-(id)usernameForConnection:(id)arg1 ;
-(id)typeForConnection:(id)arg1 ;
-(id)localIPForSpecifier:(id)arg1 ;
-(id)remoteIPForSpecifier:(id)arg1 ;
- (void)_vpnConfigurationChanged:(id)arg1;
@end

// %hook VPNConnectionStore
// -(BOOL)setRemoteAddress:(id)arg1 ofService:(SCNetworkServiceRef)arg2 vpnType:(int)arg3 {
// 	NSLog(@"MYHOOK remoteip: %@, %d", arg1, arg3);
// 	return %orig;
// }
// %end

%hook VPNController
- (void)_vpnConfigurationChanged:(id)arg1 {
	NSLog(@"MYHOOK vpnchagne: %@", arg1);
	%orig;
}
-(id)serverForConnection:(id)arg1  {
	id res = %orig;
	NSLog(@"MYHOOK server: %@, %@", arg1, res);
	return res;
}
-(id)usernameForConnection:(id)arg1 {
	id res = %orig;
	NSLog(@"MYHOOK username: %@, %@", arg1, res);
	return res;
}
-(id)typeForConnection:(id)arg1  {
	id res = %orig;
	NSLog(@"MYHOOK type: %@, %@", arg1, res);
	return res;
}
-(id)localIPForSpecifier:(id)arg1  {
	id res = %orig;
	NSLog(@"MYHOOK lip: %@, %@", arg1, res);
	return res;
}
-(id)remoteIPForSpecifier:(id)arg1  {
	id res = %orig;
	NSLog(@"MYHOOK rip: %@, %@", arg1, res);
	return res;
}

%end


static void load(NSString* bundleID){
	NSDictionary* info = [NSDictionary dictionaryWithContentsOfFile:m_preferences_plist];
	NSMutableArray* allowsList = info[@"allowsList"];
	NSDictionary* config = info[@"config"];
	NSLog(@"MYHOOK config: %@ :: %@", info, bundleID);

	if (bundleID != nil && allowsList != nil && [allowsList containsObject:bundleID]){
		NSBundle* VPNPreferences = [NSBundle bundleWithPath:@"/System/Library/PreferenceBundles/VPNPreferences.bundle"];
		if ([VPNPreferences load] == YES){
			Class VPC = NSClassFromString(@"VPNBundleController");
			[VPNPreferences release];
			if (VPC != NULL){
				// VPNSetupListController* vpnSetup = [[NSClassFromString(@"VPNSetupListController") alloc] init];
			// 	// NSString *username = config[@"username"];
			// 	// NSString *password = config[@"password"];
			// 	// NSString *server = config[@"server"];
			// 	// NSString *type = config[@"type"];
			// 	// NSString *name = config[@"name"];
			// 	// [vpnSetup setDisplayName:name forSpecifier:nil];
			// 	// [vpnSetup setVPNType:(__bridge CFStringRef)type forSpecifier:nil];
			// 	// [vpnSetup setServer:server forSpecifier:nil];
			// 	// [vpnSetup setUsername:username forSpecifier:nil];
			// 	// [vpnSetup setPassword:password forSpecifier:nil];
			// 	// [vpnSetup setPPTPEncryptionLevel:@1 forSpecifier:nil];
			// 	// 
			// 	// [vpnSetup setSendAllTraffic:[NSNumber numberWithBool:YES] forSpecifier:nil];
			// 	// 
			// 	// Ivar ivar = class_getInstanceVariable([vpnSetup class], "_updateButton");
			// 	// NSString *a = [[VPNPreferences localizedStringForKey:@"UPDATE_VPN" value:@"" table:@"MobileVPN"] retain];
			// 	// PSSpecifier *p = [[NSClassFromString(@"PSSpecifier") preferenceSpecifierNamed:a target:vpnSetup set:0x0 get:0x0 detail:0x0 cell:0xd edit:0x0] retain];
			// 	// [p setButtonAction:@selector(saveButtonTapped:)];
			// 	// object_setIvar(vpnSetup, ivar, (id)p);
			// 	// [vpnSetup saveButtonTapped:MSHookIvar<PSSpecifier *>(vpnSetup, "_updateButton")];
			// 	// NSLog(@"MYHOOK aa: %@", MSHookIvar<NSString*>(vpnSetup, "_serviceID"));
			// 	// Ivar a = class_getInstanceVariable([NSClassFromString(@"VPNSetupListController") class], "_serviceID");
			// 	
			// 	// object_setIvar(vpnSetup, a, (id)@"7DF417CB-4B07-422A-9BB8-496A239FEBD8");
			// 	
			// 
			// 	// NSLog(@"MYHOOK ---> %@", [vpnSetup specifiers]);
			// 		// [vpnSetup _saveConfigurationSettings];
			// 
			// 	VPNBundleController* VPNBC = [[VPC alloc] initWithParentListController:nil];
			// 	id PSS = MSHookIvar<PSSpecifier *>(VPNBC, "_vpnSpecifier");
			// 	// if ([MSHookIvar<NSNumber *>(VPNBC, "_serviceCount") intValue] <= 0) {
			// 	// 	[vpnSetup _saveConfigurationSettings];
			// 	// 	NSLog(@"MYHOOK save configure");
			// 	// }
			// 
			// 	NSLog(@"MYHOOK PSS: %@", PSS);
			// 	if([[VPNBC vpnActiveForSpecifier:PSS] boolValue] == YES){
			// 		   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"消息" 
		    //                                                 message:@"VPN 已经连接" 
		    //                                                 delegate:nil
		    //                                                 cancelButtonTitle:@"OK" 
		    //                                                 otherButtonTitles:nil];
		    // 			[alert show];
		    // 			[alert release];
			// 	}
			// 	else{
			// 		if ([VPNBC respondsToSelector:@selector(setVPNActive:)]){
			// 			[VPNBC setVPNActive:YES];
			// 		}
			// 		else if ([VPNBC respondsToSelector:@selector(_setVPNActive:)]){
			// 			[VPNBC _setVPNActive:YES];
			// 		}
			// 		else{
		    // 			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"消息" 
		    //                                                 message:@"VPN 连接失败" 
		    //                                                 delegate:nil
		    //                                                 cancelButtonTitle:@"OK" 
		    //                                                 otherButtonTitles:nil];
		    // 			[alert show];
		    // 			[alert release];
			// 		}
			// 	}
				// [VPNBC release];
			}
		}
		else{
			// NSLog(@"VPNPreferences.bundle Loading Failed");
		    // UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"消息" 
	        //                                     message:@"VPN加载失败" 
	        //                                     delegate:nil
	        //                                     cancelButtonTitle:@"OK" 
	        //                                     otherButtonTitles:nil];
			// [alert show];
			// [alert release];
		}
	}
}

%hook SBUIController
- (void)activateApplicationAnimated:(id)arg1{
	// load([arg1 bundleIdentifier]);
	%orig;

}
- (void)activateApplicationAnimated:(id)arg1 fromIcon:(id)arg2 location:(int)arg3{
	// load([arg1 bundleIdentifier]);
	%orig;

}

%end
%ctor {
    @autoreleasepool
    { 
		load([[NSBundle mainBundle]bundleIdentifier]);
	}
}

static 	UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
static 	UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
static UIButton *btn3 = [UIButton buttonWithType:UIButtonTypeCustom];
// static BOOL opened = NO;


%hook UINavigationController




%end
dispatch_queue_t queue = dispatch_queue_create("gcdtest.rongfzh.yc", DISPATCH_QUEUE_CONCURRENT);  

%hook PSSplitViewController

%new
- (void)doVPN {
	NSLog(@"MYHOOK doVPN");
	NSBundle* VPNPreferences = [NSBundle bundleWithPath:@"/System/Library/PreferenceBundles/VPNPreferences.bundle"];
	if ([VPNPreferences load] == YES){
		id VPNBC = [[NSClassFromString(@"VPNBundleController") alloc] initWithParentListController:nil];
		NSLog(@"MYHOOK status:==> %@", VPNBC);
		// BOOL status = [[self vpnStatus] boolValue];
		// NSLog(@"MYHOOK -====> %@, %@",  ? @"YES":@"NO", status ? @"YES":@"NO");
		BOOL status = [[VPNBC vpnActiveForSpecifier:nil] boolValue];
		NSLog(@"MYHOOK good status: ");
		if ([VPNBC respondsToSelector:@selector(setVPNActive:)]){
			NSLog(@"MYHOOK yes");
			[VPNBC setVPNActive:!status];
		}
		else if ([VPNBC respondsToSelector:@selector(_setVPNActive:)]){
			NSLog(@"MYHOOK NO");
			[VPNBC _setVPNActive:!status];
		}
	} else {
		NSLog(@"MYHOOK not loaded");
	}
	[VPNPreferences release];
	dispatch_async(queue, ^{
		NSLog(@"MYHOOK dispatch");
		[NSThread sleepForTimeInterval:3];
		// BOOL status = [[[[NSClassFromString(@"VPNBundleController") alloc] initWithParentListController:nil] vpnActiveForSpecifier:nil] boolValue];;
		// NSLog(@"Status of : %@", status ? @"YES":@"NO");
		dispatch_async(dispatch_get_main_queue(), ^{
			BOOL status = [[[[NSClassFromString(@"VPNBundleController") alloc] initWithParentListController:nil] vpnActiveForSpecifier:nil] boolValue];;
			NSLog(@"Status of : %@", status ? @"YES":@"NO");
			[btn2 setBackgroundColor:status?[UIColor greenColor]:[UIColor redColor]];
			[btn2 setTitle:[NSString stringWithFormat:@"%@VPN", status?@"关闭":@"打开"] forState:UIControlStateNormal];
		});
	});

}

%new
- (BOOL)vpnStatus {
	id VPNBC = [[NSClassFromString(@"VPNBundleController") alloc] initWithParentListController:nil];
	NSLog(@"MYHOOK vpnstatus in: %@", [VPNBC vpnActiveForSpecifier:nil]);
	return [[VPNBC vpnActiveForSpecifier:nil] boolValue];
}

%new
- (void)reloadVPNConfig {
	NSMutableDictionary* info = [[NSDictionary dictionaryWithContentsOfFile:m_preferences_plist] mutableCopy];

	if ([info[@"enable"] boolValue]) {
		[[UIApplication sharedApplication ] openURL: [NSURL URLWithString:[NSString stringWithFormat:@"prefs:root=General&path=VPN/%@", info[@"config"][@"name"]]]];
	}
}

%new
- (void)disableConfigure {
	NSMutableDictionary* info = [[NSDictionary dictionaryWithContentsOfFile:m_preferences_plist] mutableCopy];
	[btn setBackgroundColor:![info[@"enable"] boolValue]?[UIColor greenColor]:[UIColor redColor]];
	info[@"enable"] = [NSNumber numberWithBool:![info[@"enable"] boolValue]];
	[info writeToFile:m_preferences_plist atomically:YES];
	[btn setTitle:[NSString stringWithFormat:@"%@配置", [info[@"enable"] boolValue]?@"关闭":@"打开"] forState:UIControlStateNormal];
}
- (void)viewWillAppear:(BOOL)animated {
	%orig;
	[[self view] addSubview:[btn retain]];
    [[self view]  addSubview:[btn2 retain]];
	[[self view] addSubview:[btn3 retain]];
}

- (void)viewDidLoad {
	%orig;
	NSMutableDictionary* info = [[NSDictionary dictionaryWithContentsOfFile:m_preferences_plist] mutableCopy];

	[btn setBackgroundColor:[UIColor redColor]];
	[btn setBackgroundColor:[info[@"enable"] boolValue]?[UIColor greenColor]:[UIColor redColor]];
	[btn setTitle:[NSString stringWithFormat:@"%@配置", [info[@"enable"] boolValue]?@"关闭":@"打开"] forState:UIControlStateNormal];
	btn.frame = CGRectMake(20, 525, 80, 40);
	[btn addTarget:self action:@selector(disableConfigure) forControlEvents:UIControlEventTouchUpInside];
	// [[[UIApplication sharedApplication ] keyWindow] addSubview:[btn retain]];
	[[self view] addSubview:[btn retain]];
	
	[btn3 setBackgroundColor:[UIColor redColor]];
	[btn3 setBackgroundColor:[UIColor orangeColor]];
	[btn3 setTitle:@"重载配置" forState:UIControlStateNormal];
	btn3.frame = CGRectMake(120, 525, 80, 40);
	[btn3 addTarget:self action:@selector(reloadVPNConfig) forControlEvents:UIControlEventTouchUpInside];
	// [[[UIApplication sharedApplication ] keyWindow]  addSubview:[btn3 retain]];
	[[self view] addSubview:[btn3 retain]];
	
	BOOL vpnSS = [[[[NSClassFromString(@"VPNBundleController") alloc] initWithParentListController:nil] vpnActiveForSpecifier:nil] boolValue];
	NSLog(@"MYHOOK vpnss: %@", vpnSS ? @"YES":@"NO");
	[btn2 setBackgroundColor:[UIColor redColor]];
	[btn2 setBackgroundColor:vpnSS?[UIColor greenColor]:[UIColor redColor]];
	[btn2 setTitle:[NSString stringWithFormat:@"%@VPN", vpnSS?@"关闭":@"打开"] forState:UIControlStateNormal];
	btn2.frame = CGRectMake(220, 525, 80, 40);
	[btn2 addTarget:self action:@selector(doVPN) forControlEvents:UIControlEventTouchUpInside];
	// [[[UIApplication sharedApplication ] keyWindow]  addSubview:btn2];
	[[self view]  addSubview:[btn2 retain]];
	
	dispatch_async(queue, ^{
		NSLog(@"MYHOOK dispatch");
		[NSThread sleepForTimeInterval:1];
		// BOOL status = [[[[NSClassFromString(@"VPNBundleController") alloc] initWithParentListController:nil] vpnActiveForSpecifier:nil] boolValue];;
		// NSLog(@"Status of : %@", status ? @"YES":@"NO");
		dispatch_async(dispatch_get_main_queue(), ^{
			BOOL status = [[[[NSClassFromString(@"VPNBundleController") alloc] initWithParentListController:nil] vpnActiveForSpecifier:nil] boolValue];;
			NSLog(@"Status of : %@", status ? @"YES":@"NO");
			[btn2 setBackgroundColor:status?[UIColor greenColor]:[UIColor redColor]];
			[btn2 setTitle:[NSString stringWithFormat:@"%@VPN", status?@"关闭":@"打开"] forState:UIControlStateNormal];
		});
	});
}
%end
