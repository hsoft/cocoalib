/* 
Copyright 2011 Hardcoded Software (http://www.hardcoded.net)

This software is licensed under the "BSD" License as described in the "LICENSE" file, 
which should be included with this package. The terms are also available at 
http://www.hardcoded.net/licenses/bsd_license
*/

#import "HSWindowController.h"
#import "Utils.h"

@implementation HSWindowController
- (id)initWithNibName:(NSString *)aNibName pyClassName:(NSString *)aClassName pyParent:(id)aPyParent;
{
    self = [super initWithWindowNibName:aNibName];
    Class pyClass = [Utils classNamed:aClassName];
    py = [[pyClass alloc] initWithCocoa:self pyParent:aPyParent];
    return self;
}

- (oneway void)release
{
    // see HSGUIController
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

- (PyGUI *)py
{
    return py;
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
