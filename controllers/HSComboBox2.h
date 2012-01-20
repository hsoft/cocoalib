/* 
Copyright 2011 Hardcoded Software (http://www.hardcoded.net)

This software is licensed under the "BSD" License as described in the "LICENSE" file, 
which should be included with this package. The terms are also available at 
http://www.hardcoded.net/licenses/bsd_license
*/

#import <Cocoa/Cocoa.h>
#import "HSGUIController2.h"
#import "PySelectableList2.h"

@interface HSComboBox2 : HSGUIController2 <NSComboBoxDataSource>
{
    NSArray *items;
}
- (id)initWithPyRef:(PyObject *)aPyRef view:(NSComboBox *)aView;
- (NSComboBox *)view;
- (void)setView:(NSComboBox *)aComboboxView;
- (PySelectableList2 *)model;

- (void)comboboxViewSelectionChanged;
- (void)refresh;
- (void)updateSelection;
@end