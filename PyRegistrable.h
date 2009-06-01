#import <Cocoa/Cocoa.h>

@interface PyRegistrable: NSObject
- (BOOL)isRegistered;
- (BOOL)isCodeValid:(NSString *)code withEmail:(NSString *)email;
- (void)setRegisteredCode:(NSString *)code andEmail:(NSString *)email;
@end