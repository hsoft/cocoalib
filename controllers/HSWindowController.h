/* 
Copyright 2010 Hardcoded Software (http://www.hardcoded.net)

This software is licensed under the "BSD" License as described in the "LICENSE" file, 
which should be included with this package. The terms are also available at 
http://www.hardcoded.net/licenses/bsd_license
*/

#import <Cocoa/Cocoa.h>
#import "PyGUI.h"

// You, it would be nice if objc had multiple inheritance...
// We need the window controllers to be NSWindowController instances if we want the window dealloc
// to be properly made when the document closes.

@interface HSWindowController : NSWindowController
{
    PyGUI *py;
}
- (id)initWithNibName:(NSString *)aNibName pyClassName:(NSString *)aClassName pyParent:(id)aPyParent;
- (void)connect;
- (void)disconnect;
@end
