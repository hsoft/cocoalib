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
    id <PySelectableList2> py;
    NSTableView *view;
    NSArray *items;
}
- initWithPy:(id <PySelectableList2>)aPy tableView:(NSTableView *)aTableView;
- (NSTableView *)view;
- (void)setView:(NSTableView *)aTableView;
- (id <PySelectableList2>)py;

- (void)refresh;
@end
