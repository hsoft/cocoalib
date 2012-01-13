/* 
Copyright 2011 Hardcoded Software (http://www.hardcoded.net)

This software is licensed under the "BSD" License as described in the "LICENSE" file, 
which should be included with this package. The terms are also available at 
http://www.hardcoded.net/licenses/bsd_license
*/

#import <Cocoa/Cocoa.h>
#import "PyGUIObject.h"

@interface HSGUIController : NSObject
{
    PyGUIObject *model;
    NSView *view;
}
- (id)initWithModel:(PyGUIObject *)aPy;
- (id)initWithModel:(PyGUIObject *)aPy view:(NSView *)aView;
- (PyGUIObject *)model;
- (NSView *)view;
- (void)setView:(NSView *)aView;
@end
