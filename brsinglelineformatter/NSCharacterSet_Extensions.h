#import <Cocoa/Cocoa.h>

// Only needed for Tiger. Remove when targeting the 10.5 SDK
@interface NSCharacterSet (NewLineCharacterSet)
+ (NSCharacterSet *)newlineCharacterSet;
@end
