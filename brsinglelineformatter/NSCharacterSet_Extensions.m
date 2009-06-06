#import "NSCharacterSet_Extensions.h"

@implementation NSCharacterSet (NewLineCharacterSet)

+ (NSCharacterSet *)newlineCharacterSet;
{
    static NSCharacterSet *newlineCharacterSet = nil;
    if (nil == newlineCharacterSet) 
	{
		// This will be a character set with all newline characters (including the weird Unicode ones)
		CFMutableCharacterSetRef newlineCFCharacterSet = NULL;
		// get all whitespace characters (does not include newlines)
		newlineCFCharacterSet = CFCharacterSetCreateMutableCopy(CFAllocatorGetDefault(), CFCharacterSetGetPredefined(kCFCharacterSetWhitespace));
		// invert the whitespace-only set to get all non-whitespace chars (the inverted set will include newlines)
		CFCharacterSetInvert(newlineCFCharacterSet);
		// now get only the characters that are common to kCFCharacterSetWhitespaceAndNewline and our non-whitespace set
		CFCharacterSetIntersect(newlineCFCharacterSet, CFCharacterSetGetPredefined(kCFCharacterSetWhitespaceAndNewline));
		newlineCharacterSet = [(id)newlineCFCharacterSet copy];
    }
    return newlineCharacterSet;
}

@end
