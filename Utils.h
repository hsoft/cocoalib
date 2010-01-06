/* 
Copyright 2010 Hardcoded Software (http://www.hardcoded.net)

This software is licensed under the "BSD" License as described in the "LICENSE" file, 
which should be included with this package. The terms are also available at 
http://www.hardcoded.net/licenses/bsd_license
*/

#import <Cocoa/Cocoa.h>

//Useful shortcuts
#define i2n(i) [NSNumber numberWithInt:i]
#define n2i(n) [n intValue]
#define b2n(b) [NSNumber numberWithBool:b]
#define n2b(n) [n boolValue]
#define f2n(f) [NSNumber numberWithFloat:f]
#define n2f(n) [n floatValue]
#define p2a(p) [Utils indexPath2Array:p]
#define a2p(a) [Utils array2IndexPath:a]

@interface Utils : NSObject
+ (NSImage *)addCircleWithCount:(int)aCount ofColor:(NSColor *)aColor withTextColor:(NSColor *)aTextColor toImage:(NSImage *)aImage;
+ (NSArray *)indexSet2Array:(NSIndexSet *)aIndexSet;
+ (NSIndexSet *)array2IndexSet:(NSArray *)numberArray;
+ (NSArray *)indexPath2Array:(NSIndexPath *)aIndexPath;
+ (NSIndexPath *)array2IndexPath:(NSArray *)indexArray;
+ (NSString *)indexPath2String:(NSIndexPath *)aIndexPath;
+ (NSIndexPath *)string2IndexPath:(NSString *)aString;
+ (BOOL)isTiger;
+ (BOOL)isLeopard;
@end
