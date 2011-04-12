/* 
Copyright 2011 Hardcoded Software (http://www.hardcoded.net)

This software is licensed under the "BSD" License as described in the "LICENSE" file, 
which should be included with this package. The terms are also available at 
http://www.hardcoded.net/licenses/bsd_license
*/

#import <Cocoa/Cocoa.h>
#import "ProgressController.h"
#import "PyFairware.h"

@interface PyApp: PyFairware <Worker>
//Worker
- (NSNumber *)getJobProgress;
- (NSString *)getJobDesc;
- (void)cancelJob;
- (void)jobCompleted:(id)jobid;
@end
