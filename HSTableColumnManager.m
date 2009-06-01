#import "HSTableColumnManager.h"
#import "Utils.h"

@implementation HSTableColumnManager
- (id)initWithTable:(NSTableView *)aTable
{
    self = [super init];
    table = [aTable retain];
    columns = [[NSMutableArray alloc] initWithArray:[aTable tableColumns]];
    defaulName2Column = [[NSMutableDictionary dictionary] retain];
    return self;
}

- (void)dealloc
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSEnumerator *e = [[defaulName2Column allKeys] objectEnumerator];
    NSString *udName;
    while (udName = [e nextObject])
        [ud removeObserver:self forKeyPath:udName];
    [defaulName2Column release];
    [table release];
    [columns release];
    [super dealloc];
}

- (NSTableColumn *)getColumn:(NSString *)columnId
{
    NSEnumerator *e = [columns objectEnumerator];
    NSTableColumn *result;
    while (result = [e nextObject])
    {
        if ([[result identifier] isEqualTo:columnId])
        {
            return result;
        }
    }
    return nil;
}

- (BOOL)isColumnVisible:(NSString *)columnId
{
    return [table tableColumnWithIdentifier:columnId] != nil;
}

- (void)linkColumn:(NSString *)columnId toUserDefault:(NSString *)udName
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [defaulName2Column setValue:columnId forKey:udName];
    [ud addObserver:self forKeyPath:udName options:NSKeyValueObservingOptionNew context:NULL];
    [self setColumn:columnId visible:[ud boolForKey:udName]];
}

- (void)setColumn:(NSString *)columnId visible:(BOOL)visible
{
    if (visible == [self isColumnVisible:columnId])
    {
        return;
    }
    NSTableColumn *column = [self getColumn:columnId];
    if (column == nil)
    {
        return;
    }
    // Before changing the columns, we must stop edition if it is ongoing
    if ([table editedColumn] >= 0)
        [[table window] makeFirstResponder:table]; // This will abort edition
    if (visible)
    {
        [table addTableColumn:column];
        // What we want to find is the index of the column just before our column *in* the table view
        // Because there might be some invisible columns before our column that will offset targetPosition
        NSEnumerator *e = [columns objectEnumerator];
        NSTableColumn *c;
        int targetPosition = 0;
        while ((c = [e nextObject]) && (c != column))
        {
            if ([[table tableColumns] containsObject:c])
            {
                targetPosition++;
            }
        }
        int sourcePosition = [table numberOfColumns] - 1;
        if (sourcePosition != targetPosition)
        {
            [table moveColumn:sourcePosition toColumn:targetPosition];
        }
    }
    else
    {
        [table removeTableColumn:column];
    }
    [table sizeToFit];
}

- (void)toggleColumnVisibility:(NSString *)columnId
{
    [self setColumn:columnId visible:![self isColumnVisible:columnId]];
}

/* Delegate */

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    BOOL visible = n2b([change objectForKey:NSKeyValueChangeNewKey]);
    NSString *columnId = [defaulName2Column objectForKey:keyPath];
    [self setColumn:columnId visible:visible];
}

@end