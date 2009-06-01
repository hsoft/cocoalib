#import "RecentDirectories.h"

@implementation RecentDirectories
- (IBAction)clearMenu:(id)sender
{
    [directories removeAllObjects];
    [self rebuildMenu];
}

- (IBAction)menuClick:(id)sender
{
    if (delegate == nil)
        return;
    if ([delegate respondsToSelector:@selector(recentDirecoryClicked:)])
        [delegate recentDirecoryClicked:[directories objectAtIndex:[sender tag]]];
}

- (id)init
{
    self = [super init];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    directories = [[NSMutableArray alloc] initWithArray:[ud arrayForKey:@"recentDirectories"]];
    NSFileManager *fm = [NSFileManager defaultManager];
    for (int i=[directories count]-1;i>=0;i--)
    {
        if (![fm fileExistsAtPath:[directories objectAtIndex:i]])
            [directories removeObjectAtIndex:i];
    }
    return self;
}

- (void)dealloc
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:directories forKey:@"recentDirectories"];
    [ud synchronize];
    [directories release];
    [super dealloc];
}

- (void)awakeFromNib
{
    [self rebuildMenu];
}

- (void)addDirectory:(NSString *)directory
{
    [directories removeObject:directory];
    [directories insertObject:directory atIndex:0];
    [self rebuildMenu];
}

- (void)rebuildMenu
{
    while ([menu numberOfItems] > 0)
        [menu removeItemAtIndex:0];
    [self fillMenu:menu];
    [menu addItem:[NSMenuItem separatorItem]];
    NSMenuItem *mi = [menu addItemWithTitle:@"Clear List" action:@selector(clearMenu:) keyEquivalent:@""];
    [mi setTarget:self];
}

- (void)fillMenu:(NSMenu *)menuToFill
{
    for (int i=0;i<[directories count];i++)
    {
        NSMenuItem *mi = [menuToFill addItemWithTitle:[directories objectAtIndex:i] action:@selector(menuClick:) keyEquivalent:@""];
        [mi setTag:i];
        [mi setTarget:self];
    }
}

/* Properties */
- (NSMenu *)menu {return menu;}
- (NSArray *)directories {return directories;}
@end
