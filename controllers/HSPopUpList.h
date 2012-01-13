/* 
Copyright 2011 Hardcoded Software (http://www.hardcoded.net)

This software is licensed under the "BSD" License as described in the "LICENSE" file, 
which should be included with this package. The terms are also available at 
http://www.hardcoded.net/licenses/bsd_license
*/

#import <Cocoa/Cocoa.h>
#import <Python.h>
#import "PySelectableList.h"

@interface HSPopUpList : NSObject
{
    PySelectableList *py;
    NSPopUpButton *view;
}
- (id)initWithPyRef:(PyObject *)aPyRef popupView:(NSPopUpButton *)aPopupView;
- (NSPopUpButton *)view;
- (void)setView:(NSPopUpButton *)aPopupView;
- (PySelectableList *)py;

- (void)popupViewSelectionChanged;
- (void)refresh;
- (void)updateSelection;
@end