/* 
Copyright 2011 Hardcoded Software (http://www.hardcoded.net)

This software is licensed under the "BSD" License as described in the "LICENSE" file, 
which should be included with this package. The terms are also available at 
http://www.hardcoded.net/licenses/bsd_license
*/

#import <Cocoa/Cocoa.h>
#import "PyGUI.h"

@interface HSGUIController : NSObject
{
    PyGUI *py;
    NSView *view;
}
- (id)initWithPyClassName:(NSString *)aClassName pyParent:(id)aPyParent;
- (id)initWithPy:(id)aPy;
- (id)initWithPyClassName:(NSString *)aClassName pyParent:(id)aPyParent view:(NSView *)aView;
- (id)initWithPy:(id)aPy view:(NSView *)aView;
- (NSView *)view;
- (void)setView:(NSView *)aView;
- (void)connect;
- (void)disconnect;
@end
