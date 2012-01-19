/* 
Copyright 2011 Hardcoded Software (http://www.hardcoded.net)

This software is licensed under the "BSD" License as described in the "LICENSE" file, 
which should be included with this package. The terms are also available at 
http://www.hardcoded.net/licenses/bsd_license
*/

#import <Cocoa/Cocoa.h>
#import "PySelectableList2.h"

@interface HSSelectableList2 : NSObject <NSTableViewDelegate, NSTableViewDataSource>
{
    PySelectableList2 *model;
    NSTableView *view;
    NSArray *items;
}
- initWithModel:(PySelectableList2 *)aPy tableView:(NSTableView *)aTableView;
- initWithPyRef:(PyObject *)aPyRef tableView:(NSTableView *)aTableView;
- (NSTableView *)view;
- (void)setView:(NSTableView *)aTableView;
- (PySelectableList2 *)model;

- (void)refresh;
@end
