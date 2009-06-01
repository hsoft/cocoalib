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