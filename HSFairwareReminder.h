/* 
Copyright 2012 Hardcoded Software (http://www.hardcoded.net)

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
    IBOutlet NSButton *registerOperatingSystemButton;
    IBOutlet NSPanel *fairwareNagPanel;
    IBOutlet NSTextField *fairwarePromptTextField;
    IBOutlet NSTextField *fairwareUnpaidHoursTextField;
    IBOutlet NSPanel *demoNagPanel;
    IBOutlet NSTextField *demoPromptTextField;
    
    NSNib *_nib;
    PyFairware *app;
}
//Show nag only if needed
+ (BOOL)showFairwareNagWithApp:(PyFairware *)app prompt:(NSString *)prompt;
+ (BOOL)showDemoNagWithApp:(PyFairware *)app prompt:(NSString *)prompt;
- (id)initWithApp:(PyFairware *)app;

- (IBAction)contribute:(id)sender;
- (IBAction)buy:(id)sender;
- (IBAction)moreInfo:(id)sender;
- (IBAction)cancelCode:(id)sender;
- (IBAction)enterCode:(id)sender;
- (IBAction)submitCode:(id)sender;
- (IBAction)closeDialog:(id)sender;

- (BOOL)showNagPanel:(NSPanel *)panel; //YES: The code has been sucessfully submitted NO: The use wan't to try the demo.
- (BOOL)showFairwareNagPanelWithPrompt:(NSString *)prompt;
- (BOOL)showDemoNagPanelWithPrompt:(NSString *)prompt;
- (NSInteger)enterCode; //returns the modal code.
@end
