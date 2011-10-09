/* 
Copyright 2011 Hardcoded Software (http://www.hardcoded.net)

This software is licensed under the "BSD" License as described in the "LICENSE" file, 
which should be included with this package. The terms are also available at 
http://www.hardcoded.net/licenses/bsd_license
*/

#import <Cocoa/Cocoa.h>
#import "HSGUIController.h"
#import "PyTable.h"

@interface HSTable : HSGUIController <NSTableViewDelegate, NSTableViewDataSource>
{
    NSTableView *tableView;
}
- (id)initWithPyClassName:(NSString *)aClassName pyParent:(id)aPyParent view:(NSTableView *)aTableView;
- (id)initWithPy:(id)aPy view:(NSTableView *)aTableView;

/* Virtual */
- (PyTable *)py;

/* Public */
- (void)refresh;
- (void)showSelectedRow;
- (void)updateSelection;
@end
