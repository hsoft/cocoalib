/* 
Copyright 2009 Hardcoded Software (http://www.hardcoded.net)

This software is licensed under the "BSD" License as described in the "LICENSE" file, 
which should be included with this package. The terms are also available at 
http://www.hardcoded.net/licenses/bsd_license
*/

#import <Cocoa/Cocoa.h>

@interface PyRegistrable: NSObject
- (BOOL)isRegistered;
- (BOOL)isCodeValid:(NSString *)code withEmail:(NSString *)email;
- (void)setRegisteredCode:(NSString *)code andEmail:(NSString *)email;
@end