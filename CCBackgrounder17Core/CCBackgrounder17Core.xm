#import <Foundation/Foundation.h>
#import <rootless.h>

#define PREFS_PATH ROOT_PATH_NS(@"/var/mobile/Library/Preferences/com.0xkuj.ccbackgrounder17.prefs.plist")

@interface NSObject (CCBackgrounder17SettingsSetter)
- (void)setForeground:(BOOL)foreground;
@end

@interface FBScene : NSObject
@end

@interface SBApplication : NSObject
- (NSString *)bundleIdentifier;
@end

@interface CCUIToggleModule : NSObject
- (BOOL)isSelected;
- (void)setSelected:(BOOL)selected;
- (void)refreshState;
@end

@interface CCUIToggleViewController : NSObject
@end

@interface SpringBoard : NSObject
@end

@interface CCBackgrounder17Manager : NSObject
+ (void)setForeground:(NSString *)identifier WithBool:(BOOL)flag;
+ (BOOL)isForeground:(NSString *)identifier;
@end

@implementation CCBackgrounder17Manager

+ (NSMutableArray *)_foregroundIdentifiers {
	static NSMutableArray *identifiers;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		identifiers = [NSMutableArray new];
	});
	return identifiers;
}

+ (void)setForeground:(NSString *)identifier WithBool:(BOOL)flag {
	if (!identifier) return;
	NSMutableArray *identifiers = [self _foregroundIdentifiers];
	if (flag) {
		if (![identifiers containsObject:identifier]) {
			[identifiers addObject:identifier];
		}
	} else {
		[identifiers removeObject:identifier];
	}
}

// `identifier` may be a bare bundle identifier (from the CC toggle / SBApplication)
// or a scene identifier of the form "sceneID:<bundleIdentifier>-<sceneRole>" (from
// FBScene). SpringBoard's own scene has no "sceneID:" prefix at all. Match by
// prefix against each stored bundle identifier rather than requiring exact
// equality, so every calling convention resolves correctly.
+ (BOOL)isForeground:(NSString *)identifier {
	if (!identifier) return NO;
	for (NSString *bundleIdentifier in [self _foregroundIdentifiers]) {
		if ([identifier isEqualToString:bundleIdentifier]) return YES;
		if ([identifier hasPrefix:[bundleIdentifier stringByAppendingString:@"-"]]) return YES;
		NSString *sceneIdentifierPrefix = [NSString stringWithFormat:@"sceneID:%@", bundleIdentifier];
		if ([identifier isEqualToString:sceneIdentifierPrefix] ||
			[identifier hasPrefix:[sceneIdentifierPrefix stringByAppendingString:@"-"]]) {
			return YES;
		}
	}
	return NO;
}

@end

%hook FBScene

- (void)updateSettings:(id)settings withTransitionContext:(id)transitionContext completion:(id)completion {
	NSString *identifier = [self valueForKey:@"identifier"];
	BOOL enabled = identifier && [CCBackgrounder17Manager isForeground:identifier];

	// FBSSettings-family objects come in immutable/mutable pairs (e.g.
	// UIApplicationSceneSettings vs. UIMutableApplicationSceneSettings). Both
	// respond to -setForeground: (inherited generic property-setter machinery),
	// but calling it on the immutable variant traps inside FrontBoardServices
	// instead of failing gracefully. Only mutate when it's actually mutable.
	Class mutableSettingsClass = NSClassFromString(@"UIMutableApplicationSceneSettings");
	BOOL isMutable = mutableSettingsClass && [settings isKindOfClass:mutableSettingsClass];
	if (enabled && isMutable && [settings respondsToSelector:@selector(setForeground:)]) {
		[settings setForeground:YES];
	}
	%orig;
}

%end

%hook SBApplication

- (void)_didExitWithContext:(id)context {
	NSString *bundleIdentifier = [self valueForKey:@"bundleIdentifier"];
	if (bundleIdentifier) {
		[CCBackgrounder17Manager setForeground:bundleIdentifier WithBool:NO];
	}
	%orig;
}

%end

static id gToggleModule;
static NSDictionary *gPrefs;
static BOOL gAutoToggleEnabled;

static void loadPrefs() {
	gPrefs = [NSDictionary dictionaryWithContentsOfFile:PREFS_PATH];
	id enabledValue = gPrefs[@"isTweakEnabled"];
	gAutoToggleEnabled = enabledValue ? [enabledValue boolValue] : YES;
}

%hook CCUIToggleViewController

- (void)setModule:(id)module {
	%orig;
	if ([module isKindOfClass:NSClassFromString(@"CCBackgrounder17Toggle")]) {
		gToggleModule = module;
	}
}

%end

%hook SpringBoard

- (void)frontDisplayDidChange:(id)application {
	%orig;
	if (!application || !gAutoToggleEnabled || !gToggleModule || [gToggleModule isSelected] ||
		![application isKindOfClass:NSClassFromString(@"SBApplication")]) {
		return;
	}

	NSString *bundleIdentifier = [(SBApplication *)application bundleIdentifier];
	if (!bundleIdentifier) return;

	// AltList's PSLinkListCell multi-selection can store its selection as either
	// an NSArray of bundle identifiers or an NSDictionary keyed by bundle
	// identifier depending on version/config - enumerate generically (yields
	// array elements or dictionary keys, both NSStrings) instead of assuming
	// either shape, so this doesn't crash if it's not the shape we expect.
	BOOL isAppSelected = NO;
	for (id key in gPrefs[@"selectedApps"]) {
		if ([key isEqualToString:bundleIdentifier]) {
			isAppSelected = YES;
			break;
		}
	}

	if (isAppSelected) {
		[(CCUIToggleModule *)gToggleModule setSelected:YES];
		[(CCUIToggleModule *)gToggleModule refreshState];
	}
}

%end

%ctor {
	loadPrefs();
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.0xkuj.ccbackgrounder17.prefs.settingschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
}
