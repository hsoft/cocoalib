#import "HSErrorReportWindow.h"

@implementation HSErrorReportWindow
+ (void)showErrorReportWithContent:(NSString *)content
{
    HSErrorReportWindow *report = [[HSErrorReportWindow alloc] initWithContent:content];
    [NSApp runModalForWindow:[report window]];
    [report release];
}

- (id)initWithContent:(NSString *)content
{
    self = [super initWithWindowNibName:@"ErrorReportWindow"];
    [self window];
    [contentTextView alignLeft:nil];
    [[[contentTextView textStorage] mutableString] setString:content];
    return self;
}

- (IBAction)send:(id)sender
{
    NSString *text = [[contentTextView textStorage] string];
    NSString *URL = [NSString stringWithFormat:@"mailto:support@hardcoded.net?SUBJECT=Error Report&BODY=%@",text];
    NSString *encodedURL = [URL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:encodedURL]];

    [[self window] orderOut:self];
    [NSApp stopModalWithCode:NSOKButton];
}

- (IBAction)dontSend:(id)sender
{
    [[self window] orderOut:self];
    [NSApp stopModalWithCode:NSCancelButton];
}
@end