/* 
Copyright 2010 Hardcoded Software (http://www.hardcoded.net)

This software is licensed under the "BSD" License as described in the "LICENSE" file, 
which should be included with this package. The terms are also available at 
http://www.hardcoded.net/licenses/bsd_license
*/

#import <Cocoa/Cocoa.h>
#import "PyApp.h"

@interface TableView : NSTableView
{
    IBOutlet PyApp *py;
    
    NSMutableArray *_buffer;
    NSIndexSet *_marked;
}
//Properties
- (NSIndexSet *)markedIndexes;
- (void)setMarkedIndexes:(NSIndexSet *)aMarkedIndexes;
- (PyApp *)py;
- (void)setPy:(PyApp *)aPy;

//Public
- (id)bufferValueForRow:(int)aRow column:(int)aColumn;

//Delegate
- (int)numberOfRowsInTableView:(NSTableView *)aTableView;
- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex;
@end

