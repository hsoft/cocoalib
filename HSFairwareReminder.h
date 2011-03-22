/* 
Copyright 2010 Hardcoded Software (http://www.hardcoded.net)

This software is licensed under the "BSD" License as described in the "LICENSE" file, 
which should be included with this package. The terms are also available at 
http://www.hardcoded.net/licenses/bsd_license
*/

#import <Cocoa/Cocoa.h>
#import "PyFairware.h"

@interface HSFairwareReminder : NSObject
{
    IBOutlet NSPanel *codePanel;
    IBOutlet NSTextField *codePromptTextField;
    IBOutlet NSTextField *codeTextField;
    IBOutlet NSTextField *emailTextField;
    IBOutlet NSPanel *nagPanel;
    IBOutlet NSTextField *nagPromptTextField;
    IBOutlet NSTextField *nagUnpaidHoursTextField;
    
    NSNib *_nib;
    PyFairware *app;
}
//Show nag only if needed
+ (BOOL)showNagWithApp:(PyFairware *)app;
- (id)initWithApp:(PyFairware *)app;

- (IBAction)contribute:(id)sender;
- (IBAction)moreInfo:(id)sender;
- (IBAction)cancelCode:(id)sender;
- (IBAction)enterCode:(id)sender;
- (IBAction)submitCode:(id)sender;
- (IBAction)closeDialog:(id)sender;
- (IBAction)sendDontContributeText:(id)sender;
- (IBAction)cancelDontContribute:(id)sender;

- (BOOL)showNag; //YES: The code has been sucessfully submitted NO: The use wan't to try the demo.
- (NSInteger)enterCode; //returns the modal code.
@end
