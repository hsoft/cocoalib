#import <Cocoa/Cocoa.h>


@interface Dialogs : NSObject
+ (void)showMessage:(NSString *)message;
+ (int)askYesNo:(NSString *)message;
@end
