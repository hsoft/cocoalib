/* 
Copyright 2010 Hardcoded Software (http://www.hardcoded.net)

This software is licensed under the "HS" License as described in the "LICENSE" file, 
which should be included with this package. The terms are also available at 
http://www.hardcoded.net/licenses/hs_license
*/

#import <Cocoa/Cocoa.h>
#import "NSTableViewAdditions.h"


@interface HSTableView : NSTableView 
{
    BOOL manualEditionStop;
}
- (void)updateSelection;
- (void)stopEditing;
@end

@interface NSObject(HSTableViewDelegate)
- (NSIndexSet *)selectedIndexes;
- (void)tableViewDidEndEditing:(HSTableView *)tableView;
- (void)tableViewCancelsEdition:(HSTableView *)tableView;
- (void)tableViewWasDoubleClicked:(HSTableView *)tableView;
@end

