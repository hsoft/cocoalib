/* 
Copyright 2011 Hardcoded Software (http://www.hardcoded.net)

This software is licensed under the "BSD" License as described in the "LICENSE" file, 
which should be included with this package. The terms are also available at 
http://www.hardcoded.net/licenses/bsd_license
*/

#import <Cocoa/Cocoa.h>
#import "PyGUIObject2.h"

@interface HSGUIController2 : NSObject
{
    PyGUIObject2 *model;
    NSView *view;
}
- (id)initWithModel:(PyGUIObject2 *)aPy;
- (id)initWithModel:(PyGUIObject2 *)aPy view:(NSView *)aView;
- (PyGUIObject2 *)model;
- (NSView *)view;
- (void)setView:(NSView *)aView;
@end
