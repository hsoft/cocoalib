/* 
Copyright 2011 Hardcoded Software (http://www.hardcoded.net)

This software is licensed under the "BSD" License as described in the "LICENSE" file, 
which should be included with this package. The terms are also available at 
http://www.hardcoded.net/licenses/bsd_license
*/

#import "HSColumns.h"
#import "Utils.h"
#import "HSTableView.h" // To prevent warning on stopEditing

@implementation HSColumns
- (id)initWithPy:(id)aPy tableView:(NSTableView *)aTableView
{
    self = [super initWithPy:aPy view:aTableView];
    tableView = [aTableView retain];
    [self connectNotifications];
    return self;
}

- (void)dealloc
{
    [self disconnectNotifications];
    [tableView release];
    [super dealloc];
}

- (PyColumns *)py
{
    return (PyColumns *)py;
}

- (void)connectNotifications
{
    if (tableView == nil) {
        /* This can happen if there something broken somewhere, and even though when that happens,
           it means that something serious is going on, the fact that we connect to all columnMoved:
           events messes thigs up even MORE. Don't connect when tableView is nil!
        */
        return;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(columnMoved:)
        name:NSTableViewColumnDidMoveNotification object:tableView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(columnMoved:)
        name:NSOutlineViewColumnDidMoveNotification object:tableView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(columnResized:)
        name:NSTableViewColumnDidResizeNotification object:tableView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(columnResized:)
        name:NSOutlineViewColumnDidResizeNotification object:tableView];
}

- (void)disconnectNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/*
    It is assumed, when this method is used, that the table/outline is empty *OR* that it is not
    defined in the column list.
    
    Special note about NSOutlineView. You can use HSColumns on outline views, but you be aware that
    the "main" column (the one having the tree disclosure buttons) cannot be removed. Therefore,
    it has to be defined in the XIB and it must *not* be in column defs.
*/
- (void)initializeColumns:(HSColumnDef *)columns
{
    /* We don't want default widths to overwrite stored with in the core code */
    [self disconnectNotifications];
    /* Translate the title of columns (needed for outlines) present already */
    for (NSTableColumn *c in [tableView tableColumns]) {
        NSString *title = NSLocalizedStringFromTable([[c headerCell] stringValue], @"columns", @"");
        [[c headerCell] setStringValue:title];
    }
    NSUserDefaults *udc = [NSUserDefaultsController sharedUserDefaultsController];
    HSColumnDef *cdef = columns;
    while (cdef->attrname != nil) {
        if ([tableView tableColumnWithIdentifier:cdef->attrname] != nil) {
            cdef++;
            continue;
        }
        NSTableColumn *c = [[[NSTableColumn alloc] initWithIdentifier:cdef->attrname] autorelease];
        [c setResizingMask:NSTableColumnUserResizingMask];
        /* If the column is not added right away, it causes glitches under 10.5 (minwidths instead of default widths) */
        [tableView addTableColumn:c]; 
        NSString *title = NSLocalizedStringFromTable(cdef->title, @"columns", @"");
        [[c headerCell] setStringValue:title];
        if (cdef->sortable) {
            NSSortDescriptor *d = [[[NSSortDescriptor alloc] initWithKey:cdef->attrname ascending:YES] autorelease];
            [c setSortDescriptorPrototype:d];
        }
        [c setWidth:cdef->defaultWidth];
        [c setMinWidth:cdef->minWidth];
        NSUInteger maxWidth = cdef->maxWidth;
        if (maxWidth == 0) {
            maxWidth = 0xffffff;
        }
        [c setMaxWidth:maxWidth];
        if (cdef->cellClass != nil) {
            id cell = [[[cdef->cellClass alloc] initTextCell:@""] autorelease];
            [cell setEditable:YES];
            [c setDataCell:cell];
        }
        [c bind:@"fontSize" toObject:udc withKeyPath:@"values.TableFontSize" options:nil];
        cdef++;
    }
    [self connectNotifications];
}

/* Notifications */
- (void)columnMoved:(NSNotification *)notification
{
    /* We only get this call after the move. Although there's "NSOldColumn" and "NSNewColumn",
       the old index is irrelevant since we have to find the moved column's name.
    */
    NSInteger index = n2i([[notification userInfo] objectForKey:@"NSNewColumn"]);
    NSTableColumn *c = [[tableView tableColumns] objectAtIndex:index];
    NSString *colName = [c identifier];
    [[self py] moveColumn:colName toIndex:index];
}

- (void)columnResized:(NSNotification *)notification
{
    NSTableColumn *c = [[notification userInfo] objectForKey:@"NSTableColumn"];
    [[self py] resizeColumn:[c identifier] toWidth:[c width]];
}

/* Python --> Cocoa */
- (void)restoreColumns
{
    [self disconnectNotifications];
    NSArray *columnOrder = [[self py] columnNamesInOrder];
    for (NSInteger i=0; i<[columnOrder count]; i++) {
        NSString *colName = [columnOrder objectAtIndex:i];
        NSInteger index = [tableView columnWithIdentifier:colName];
        if ((index != -1) && (index != i)) {
            [tableView moveColumn:index toColumn:i];
        }
    }
    for (NSTableColumn *c in [tableView tableColumns]) {
        NSInteger width = [[self py] columnWidth:[c identifier]];
        if (width > 0) {
            [c setWidth:width];
        }
        BOOL isVisible = [[self py] columnIsVisible:[c identifier]];
        [c setHidden:!isVisible];
    }
    [self connectNotifications];
}

- (void)setColumn:(NSString *)colname visible:(BOOL)visible
{
    NSTableColumn *col = [tableView tableColumnWithIdentifier:colname];
    if (col == nil)
        return;
    if ([col isHidden] == !visible)
        return;
    if ([tableView respondsToSelector:@selector(stopEditing)]) {
        [(id)tableView stopEditing];
    }
    [col setHidden:!visible];
}
@end