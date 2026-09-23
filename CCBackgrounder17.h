#import <ControlCenterUIKit/CCUIToggleModule.h>

@interface CCBackgrounder17Manager : NSObject
+ (void)setForeground:(NSString *)identifier WithBool:(BOOL)flag;
+ (BOOL)isForeground:(NSString *)identifier;
@end

@interface CCBackgrounder17Toggle : CCUIToggleModule
{
	BOOL _selected;
}
@end
