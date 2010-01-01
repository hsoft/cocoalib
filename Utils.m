/* 
Copyright 2010 Hardcoded Software (http://www.hardcoded.net)

This software is licensed under the "BSD" License as described in the "LICENSE" file, 
which should be included with this package. The terms are also available at 
http://www.hardcoded.net/licenses/bsd_license
*/

#import "Utils.h"
#import <CoreServices/CoreServices.h>

@implementation Utils
+ (NSImage *)addCircleWithCount:(int)aCount ofColor:(NSColor *)aColor withTextColor:(NSColor *)aTextColor toImage:(NSImage *)aImage
{
    NSImage *r = [[[NSImage alloc] initWithSize:[aImage size]] autorelease];
    NSString *s = [[NSNumber numberWithInt:aCount] stringValue];
    int circleWidth = 18;
    if ([s length] > 2)
        circleWidth += (8 * ([s length] - 2));
    NSRect circleRect = NSMakeRect(0, [r size].height - 18, circleWidth, 18);
    [r lockFocus];
    [aImage compositeToPoint:NSZeroPoint operation:NSCompositeCopy];
    [aColor set];
    NSBezierPath *bp = [NSBezierPath bezierPathWithOvalInRect:circleRect];
    [bp fill];
    // Set string attributes
    NSMutableParagraphStyle *ps = [[[NSMutableParagraphStyle alloc] init] autorelease];
    [ps setAlignment:NSCenterTextAlignment];
    NSMutableDictionary *d = [NSMutableDictionary dictionary];
    [d setObject:ps forKey:NSParagraphStyleAttributeName];
    [d setObject:aTextColor forKey:NSForegroundColorAttributeName];
    [d setObject:[NSFont boldSystemFontOfSize:12] forKey:NSFontAttributeName];
    [s drawInRect:circleRect withAttributes:d];
    [r unlockFocus];
    return r;
}

//This is to pass index sets to python as arrays (so it can be converted to native lists)
+ (NSArray *)indexSet2Array:(NSIndexSet *)aIndexSet
{
    NSMutableArray *r = [NSMutableArray array];
    int i = [aIndexSet firstIndex];
    while (i != NSNotFound)
    {
        [r addObject:[NSNumber numberWithInt:i]];
        i = [aIndexSet indexGreaterThanIndex:i];
    }
    return r;
}

// numberArray is an array of NSNumber
+ (NSIndexSet *)array2IndexSet:(NSArray *)numberArray
{
    NSMutableIndexSet *set = [NSMutableIndexSet indexSet];
    NSEnumerator *e = [numberArray objectEnumerator];
    NSNumber *n;
    while (n = [e nextObject])
        [set addIndex:n2i(n)];
    return set;
}

//Changes an NSIndexPath into an NSArray
+ (NSArray *)indexPath2Array:(NSIndexPath *)aIndexPath
{
    NSMutableArray *r = [NSMutableArray array];
    if (!aIndexPath)
        return r;
    for (int i=0;i<[aIndexPath length];i++)
        [r addObject:i2n([aIndexPath indexAtPosition:i])];
    return r;
}

// Changes a NSArray of numbers into a NSIndexPath
// indexArray must have at least one item
+ (NSIndexPath *)array2IndexPath:(NSArray *)indexArray
{
    if (![indexArray count])
    {
        return nil;
    }
    NSEnumerator *e = [indexArray objectEnumerator];
    NSNumber *n = [e nextObject];
    NSIndexPath *ip = [NSIndexPath indexPathWithIndex:n2i(n)];
    while (n = [e nextObject])
        ip = [ip indexPathByAddingIndex:n2i(n)];
    return ip;
}

+ (NSString *)indexPath2String:(NSIndexPath *)aIndexPath
{
    NSMutableArray *components = [NSMutableArray array];
    for (int i=0; i<[aIndexPath length]; i++)
        [components addObject:i2n([aIndexPath indexAtPosition:i])];
    return [components componentsJoinedByString:@"_"];
}

+ (NSIndexPath *)string2IndexPath:(NSString *)aString
{
    if (aString == nil)
    {
        return nil;
    }
    NSArray *components = [aString componentsSeparatedByString:@"_"];
    NSMutableArray *indexes = [NSMutableArray array];
    for (int i=0; i<[components count]; i++)
        [indexes addObject:i2n([[components objectAtIndex:i] intValue])];
    return [Utils array2IndexPath:indexes];
}

+ (BOOL)isTiger
{
    SInt32 major, minor;
    Gestalt(gestaltSystemVersionMajor, &major);
    Gestalt(gestaltSystemVersionMinor, &minor);
    return (major == 10) && (minor == 4);
}

+ (BOOL)isLeopard
{
    SInt32 major, minor;
    Gestalt(gestaltSystemVersionMajor, &major);
    Gestalt(gestaltSystemVersionMinor, &minor);
    return (major == 10) && (minor == 5);
}

@end
