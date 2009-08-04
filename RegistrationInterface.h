/* 
Copyright 2009 Hardcoded Software (http://www.hardcoded.net)

This software is licensed under the "BSD" License as described in the "LICENSE" file, 
which should be included with this package. The terms are also available at 
http://www.hardcoded.net/licenses/bsd_license
*/

#import <Cocoa/Cocoa.h>
#import "PyRegistrable.h"

#define DUPEGURU_ID 4
#define DUPEGURU_ME_ID 1
#define DUPEGURU_PE_ID 5
#define MUSICGURU_ID 2
#define MONEYGURU_ID 6

#define DUPEGURU_NAME @"dupeGuru"
#define DUPEGURU_ME_NAME @"dupeGuru Music Edition"
#define DUPEGURU_PE_NAME @"dupeGuru Picture Edition"
#define MUSICGURU_NAME @"musicGuru"
#define MONEYGURU_NAME @"moneyGuru"

@interface RegistrationInterface : NSObject
{
    IBOutlet NSPanel *codePanel;
    IBOutlet NSTextField *codePromptTextField;
    IBOutlet NSTextField *codeTextField;
    IBOutlet NSTextField *emailTextField;
    IBOutlet NSPanel *nagPanel;
    IBOutlet NSTextField *nagPromptTextField;
    IBOutlet NSTextField *nagTitleTextField;
    IBOutlet NSTextField *limitDescriptionTextField;
    IBOutlet NSButton *submitButton;
    
    NSNib *_nib;
    PyRegistrable *app;
}
//Show nag only if needed
+ (BOOL)showNagWithApp:(PyRegistrable *)app name:(NSString *)appName limitDescription:(NSString *)limitDescription;
- (id)initWithApp:(PyRegistrable *)app name:(NSString *) appName limitDescription:(NSString *)limitDescription;

- (IBAction)buyNow:(id)sender;
- (IBAction)cancelCode:(id)sender;
- (IBAction)enterCode:(id)sender;
- (IBAction)submitCode:(id)sender;
- (IBAction)tryDemo:(id)sender;

- (BOOL)showNag; //YES: The code has been sucessfully submitted NO: The use wan't to try the demo.
- (int)enterCode; //returns the modal code.
@end
