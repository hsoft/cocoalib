/* 
Copyright 2012 Hardcoded Software (http://www.hardcoded.net)

This software is licensed under the "BSD" License as described in the "LICENSE" file, 
which should be included with this package. The terms are also available at 
http://www.hardcoded.net/licenses/bsd_license
*/

#import <Cocoa/Cocoa.h>
#import "PyFairware.h"

@interface HSAboutBox : NSWindowController
{
    NSTextField *titleTextField;
    NSTextField *versionTextField;
    NSTextField *copyrightTextField;
    NSTextField *registeredTextField;
    NSButton *registerButton;
    
    PyFairware *app;
}

@property (readwrite, assign) NSTextField *titleTextField;
@property (readwrite, assign) NSTextField *versionTextField;
@property (readwrite, assign) NSTextField *copyrightTextField;
@property (readwrite, assign) NSTextField *registeredTextField;
@property (readwrite, assign) NSButton *registerButton;

- (id)initWithApp:(PyFairware *)app;
- (void)updateFields;

- (void)showRegisterDialog;
@end