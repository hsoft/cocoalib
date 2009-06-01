#import <Cocoa/Cocoa.h>
#import "ProgressController.h"
#import "PyRegistrable.h"

@interface PyApp: PyRegistrable <Worker>
//Send NSArray instead of NSIndexPath. Working with NSIndexPath sucks in Python.
//Use [Utils indexPath2Array:]
//Data
// 0 if none. Returning a max level saves a lot of childCountForIndexes: calls
- (int)getOutlineViewMaxLevel:(int)tag;
// returns an array of the counts of the subitems
- (NSArray *)getOutlineView:(int)tag childCountsForPath:(NSArray *)indexPath;
- (NSArray *)getOutlineView:(NSNumber *)tag valuesForIndexes:(NSArray *)indexPath;
// 0 = unmarked, 1 = marked, 2 = unmarkable
- (NSNumber *)getOutlineView:(NSNumber *)tag markedAtIndexes:(NSArray *)indexPath;

- (NSNumber *)getTableViewCount:(NSNumber *)tag;
- (NSArray *)getTableViewMarkedIndexes:(NSNumber *)tag;
- (NSArray *)getTableView:(NSNumber *)tag valuesForRow:(NSNumber *)row;

//Worker
- (NSNumber *)getJobProgress;
- (NSString *)getJobDesc;
- (void)cancelJob;
@end
