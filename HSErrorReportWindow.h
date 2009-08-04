/* 
Copyright 2009 Hardcoded Software (http://www.hardcoded.net)

This software is licensed under the "BSD" License as described in the "LICENSE" file, 
which should be included with this package. The terms are also available at 
http://www.hardcoded.net/licenses/bsd_license
*/

#import <Cocoa/Cocoa.h>

@interface HSErrorReportWindow : NSWindowController
{
    IBOutlet NSTextView *contentTextView;
}
+ (void)showErrorReportWithContent:(NSString *)content;
- (id)initWithContent:(NSString *)content;

- (IBAction)send:(id)sender;
- (IBAction)dontSend:(id)sender;
@end