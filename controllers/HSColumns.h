/* 
Copyright 2011 Hardcoded Software (http://www.hardcoded.net)

This software is licensed under the "BSD" License as described in the "LICENSE" file, 
which should be included with this package. The terms are also available at 
http://www.hardcoded.net/licenses/bsd_license
*/

#import <Cocoa/Cocoa.h>
#import "HSGUIController.h"
#import "PyColumns.h"

/*
    This unit comes directly from MGColumns and has been pushed into cocoalib. In moneyGuru, all
    MGTable have a MGColumns instance, but I didn't do that for HSTable because I'm a bit afraid
    to break stuff in dupeGuru (We'll move HSColumns in HSTable when dupeGuru has been converted
    to HSColumns). So, when you want to use HSColumns, you have to instantiate it in your table
    manually.
*/

/*
    This structure is to define constants describing table columns (it's easier to maintain in code
    than in XIB files).
*/
typedef struct {
    NSString *attrname;
    NSUInteger defaultWidth;
    NSUInteger minWidth;
    NSUInteger maxWidth;
    BOOL sortable;
    Class cellClass;
} HSColumnDef;

@interface HSColumns : HSGUIController
{
    NSTableView *tableView;
}
- (id)initWithPy:(id)aPy tableView:(NSTableView *)aTableView;
- (PyColumns *)py;
- (void)connectNotifications;
- (void)disconnectNotifications;
- (void)initializeColumns:(HSColumnDef *)columns;
- (void)restoreColumns;
- (void)setColumn:(NSString *)colname visible:(BOOL)visible;
@end