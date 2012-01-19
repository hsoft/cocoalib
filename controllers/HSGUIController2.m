/* 
Copyright 2011 Hardcoded Software (http://www.hardcoded.net)

This software is licensed under the "BSD" License as described in the "LICENSE" file, 
which should be included with this package. The terms are also available at 
http://www.hardcoded.net/licenses/bsd_license
*/

#import "HSGUIController2.h"
#import "Utils.h"

@implementation HSGUIController2
- (id)initWithModel:(PyGUIObject2 *)aModel
{
    self = [super init];
    model = [aModel retain];
    view = nil;
    return self;
}

- (id)initWithModel:(PyGUIObject2 *)aModel view:(NSView *)aView
{
    self = [super init];
    model = [aModel retain];
    [self setView:aView];
    return self;
}

// - (oneway void)release
// {
//     // The py side hold one reference, which is why when we see that we only have 1 reference left,
//     // we must break our reference in the py side (free). We also can't call retainCount after
//     // [super release], because we might be freed. If the retainCount is 2 before the release, it
//     // will be 1 afterwards.
//     // By the way, so it is clearly remembered: The reason why we do this is because weak-referencing
//     // objc instances from python is buggy. I think it's being worked on in pyobjc. As soon as this
//     // is done, we can remove this ugly, ugly hack and simply weak reference the cocoa instance in py
//     // interfacing code.
//     if ([self retainCount] == 2) {
//         // NSLog(@"%@ free", [[self class] description]);
//         [py free];
//     }
//     [super release];
// }

- (void)dealloc
{
    // NSLog([NSString stringWithFormat:@"%@ dealloc",[[self class] description]]);
    [model release];
    [view release];
    [super dealloc];
}

- (PyGUIObject2 *)model
{
    return model;
}

- (NSView *)view
{
    return view;
}

- (void)setView:(NSView *)aView
{
    view = [aView retain];
}
@end
