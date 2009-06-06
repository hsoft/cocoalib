/*
 * Copyright (c) 2005-2006 Michele Balistreri
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE. 
 */

#import "BRSingleLineFormatter.h"
#import "NSCharacterSet_Extensions.h"


@implementation BRSingleLineFormatter

- (NSString *)stringForObjectValue:(id)anObject
{
	NSString *returnString = @"";
	NSString *tmpString = nil;
	
	NSScanner *scanner = [NSScanner scannerWithString:anObject];
	while([scanner scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:&tmpString])
		returnString = [returnString stringByAppendingString:tmpString];

	return returnString;
}

- (BOOL)getObjectValue:(id *)anObject forString:(NSString *)string errorDescription:(NSString **)error
{
	NSScanner *scanner = [NSScanner scannerWithString:string];
	NSString *tmpString = nil;
	*anObject = @"";
	while([scanner scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:&tmpString])
		*anObject = [*anObject stringByAppendingString:tmpString];
	return YES;
}

- (BOOL)isPartialStringValid:(NSString *)partialString newEditingString:(NSString **)newString errorDescription:(NSString **)error
{
	if([partialString rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]].location == NSNotFound)
		return YES;
	
	NSScanner *scanner = [NSScanner scannerWithString:partialString];
	NSString *tmpString = nil;
	*newString = @"";
		
	while([scanner scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:&tmpString])
		*newString = [*newString stringByAppendingString:tmpString];
	
	return NO;
}
@end
