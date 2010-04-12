/* 
Copyright 2010 Hardcoded Software (http://www.hardcoded.net)

This software is licensed under the "BSD" License as described in the "LICENSE" file, 
which should be included with this package. The terms are also available at 
http://www.hardcoded.net/licenses/bsd_license
*/

#import "HSGUIController.h"
#import "Utils.h"

@implementation HSGUIController
- (id)init
{
    // If you use this initialisation, you get a nil py
    return [super init];
}

- (id)initWithPyClassName:(NSString *)aClassName pyParent:(id)aPyParent
{
    self = [super init];
    Class pyClass = [Utils classNamed:aClassName];
    py = [[pyClass alloc] initWithCocoa:self pyParent:aPyParent];
    return self;
}

- (oneway void)release
{
    // The py side hold one reference, which is why when we see that we only have 1 reference left,
    // we must break our reference in the py side (free). We also can't call retainCount after
    // [super release], because we might be freed. If the retainCount is 2 before the release, it
    // will be 1 afterwards.
    if ([self retainCount] == 2) {
        // NSLog(@"%@ free", [[self class] description]);
        [py free];
    }
    [super release];
}

- (void)dealloc
{
    // NSLog([NSString stringWithFormat:@"%@ dealloc",[[self class] description]]);
    [py release];
    [super dealloc];
}

- (NSView *)view
{
    // abstract
    return nil;
}

- (void)connect
{
    [py connect];
}

- (void)disconnect
{
    [py disconnect];
}
@end
