/* 
Copyright 2009 Hardcoded Software (http://www.hardcoded.net)

This software is licensed under the "BSD" License as described in the "LICENSE" file, 
which should be included with this package. The terms are also available at 
http://www.hardcoded.net/licenses/bsd_license
*/

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
