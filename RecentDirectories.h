/* RecentDirectories */

#import <Cocoa/Cocoa.h>

@interface RecentDirectories : NSObject
{
    IBOutlet id delegate;
    IBOutlet NSMenu *menu;
    
    NSMutableArray *directories;
}
- (IBAction)clearMenu:(id)sender;
- (IBAction)menuClick:(id)sender;

- (void)addDirectory:(NSString *)directory;
- (void)rebuildMenu;
- (void)fillMenu:(NSMenu *)menu;

/* Properties */
- (NSMenu *)menu;
- (NSArray *)directories;
@end

@protocol RecentDirecoriesDelegate
- (void)recentDirecoryClicked:(NSString *)directory;
@end
