/* 
Copyright 2011 Hardcoded Software (http://www.hardcoded.net)

This software is licensed under the "BSD" License as described in the "LICENSE" file, 
which should be included with this package. The terms are also available at 
http://www.hardcoded.net/licenses/bsd_license
*/

#import <Cocoa/Cocoa.h>
#import "PyGUI.h"

@interface PySelectableList : PyGUI
- (NSArray *)items;
- (void)selectIndex:(NSInteger)index;
- (NSInteger)selectedIndex;
- (void)selectIndexes:(NSArray *)indexes;
- (NSArray *)selectedIndexes;
- (NSInteger)searchByPrefix:(NSString *)prefix;
@end