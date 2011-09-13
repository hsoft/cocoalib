/* 
Copyright 2011 Hardcoded Software (http://www.hardcoded.net)

This software is licensed under the "BSD" License as described in the "LICENSE" file, 
which should be included with this package. The terms are also available at 
http://www.hardcoded.net/licenses/bsd_license
*/

#import "HSGUIController.h"
#import "Utils.h"

@implementation HSGUIController
/* INITIALIZATION TYPES

There are two types of initialization for a py-proxy-based class. Either your instance on the py
side is not instanciated, so you want to create it. In this case, use
initWithPyClassName:pyParent: . However, it's also possible that you already have an instanciated
py class. In this case, we don't need to instanciate it ourselves, but it's imperative that we
bind our cocoa instance to our existing py instance. Anyway, in these cases, use initWithPy:
*/

- (id)initWithPyClassName:(NSString *)aClassName pyParent:(id)aPyParent
{
    self = [super init];
    Class pyClass = [Utils classNamed:aClassName];
    py = [[pyClass alloc] initWithCocoa:self pyParent:aPyParent];
    return self;
}

- (id)initWithPy:(id)aPy
{
    self = [super init];
    py = [aPy retain];
    [py bindCocoa:self];
    return self;
}

- (id)initWithPyClassName:(NSString *)aClassName pyParent:(id)aPyParent view:(NSView *)aView
{
    self = [self initWithPyClassName:aClassName pyParent:aPyParent];
    [self setView:aView];
    return self;
}

- (id)initWithPy:(id)aPy view:(NSView *)aView
{
    self = [self initWithPy:aPy];
    [self setView:aView];
    return self;
}

- (oneway void)release
{
    // The py side hold one reference, which is why when we see that we only have 1 reference left,
    // we must break our reference in the py side (free). We also can't call retainCount after
    // [super release], because we might be freed. If the retainCount is 2 before the release, it
    // will be 1 afterwards.
    // By the way, so it is clearly remembered: The reason why we do this is because weak-referencing
    // objc instances from python is buggy. I think it's being worked on in pyobjc. As soon as this
    // is done, we can remove this ugly, ugly hack and simply weak reference the cocoa instance in py
    // interfacing code.
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
    [view release];
    [super dealloc];
}

- (NSView *)view
{
    return view;
}

- (void)setView:(NSView *)aView
{
    view = [aView retain];
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
