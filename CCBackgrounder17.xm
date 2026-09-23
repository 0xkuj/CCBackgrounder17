#import <UIKit/UIKit.h>
#import "CCBackgrounder17.h"

@interface NSObject (SpringBoardFrontApp)
+ (id)sharedApplication;
- (id)_accessibilityFrontMostApplication;
@end

static NSString *currentFrontmostBundleIdentifier() {
	@try {
		id springboard = [UIApplication sharedApplication];
		if (![springboard respondsToSelector:@selector(_accessibilityFrontMostApplication)]) {
			return nil;
		}
		id frontApp = [springboard _accessibilityFrontMostApplication];
		if (!frontApp || ![frontApp respondsToSelector:@selector(bundleIdentifier)]) {
			return nil;
		}
		return [frontApp valueForKey:@"bundleIdentifier"];
	} @catch (NSException *exception) {
		return nil;
	}
}

@implementation CCBackgrounder17Toggle

- (CCUICAPackageDescription *)glyphPackageDescription {
	return [CCUICAPackageDescription descriptionForPackageNamed:@"CCBackgrounder17Toggle" inBundle:[NSBundle bundleForClass:[self class]]];
}

- (UIImage *)iconGlyph {
	return [UIImage imageNamed:@"Icon" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
}

- (UIColor *)selectedColor {
	return [UIColor colorWithRed:52 / 255.0 green:199 / 255.0 blue:89 / 255.0 alpha:1];
}

- (BOOL)isSelected {
	@try {
		Class manager = %c(CCBackgrounder17Manager);
		NSString *bundleIdentifier = currentFrontmostBundleIdentifier();
		if (!bundleIdentifier || !manager) return NO;
		return [manager isForeground:bundleIdentifier];
	} @catch (NSException *exception) {
		return NO;
	}
}

- (void)setSelected:(BOOL)selected {
	@try {
		_selected = selected;
		Class manager = %c(CCBackgrounder17Manager);
		NSString *bundleIdentifier = currentFrontmostBundleIdentifier();
		if (bundleIdentifier && manager) {
			[manager setForeground:bundleIdentifier WithBool:selected];
		}
	} @catch (NSException *exception) {
	}

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[self refreshState];
	});
}

@end
