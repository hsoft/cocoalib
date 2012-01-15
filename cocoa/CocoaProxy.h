#import <Cocoa/Cocoa.h>

@interface CocoaProxy : NSObject
{
	NSAutoreleasePool *currentPool;
}
- (void)openPath:(NSString *)path;
- (void)revealPath:(NSString *)path;
- (NSString *)getUTI:(NSString *)path;
- (BOOL)type:(NSString *)type conformsToType:(NSString *)refType;
- (NSString *)getAppdataPath; 
- (NSString *)getCachePath;
- (NSString *)getResourcePath;
- (NSString *)systemLang;
- (NSString *)bundleIdentifier;
- (NSString *)appVersion;
- (NSString *)osxVersion;
- (void)postNotification:(NSString *)name userInfo:(NSDictionary *)userInfo;
- (id)prefValue:(NSString *)prefname;
- (void)setPrefValue:(NSString *)prefname value:(id)value;
- (id)prefValue:(NSString *)prefname inDomain:(NSString *)domain;
- (NSString *)url2path:(NSString *)url;
- (void)createPool;
- (void)destroyPool;
- (void)reportCrash:(NSString *)crashReport;
@end