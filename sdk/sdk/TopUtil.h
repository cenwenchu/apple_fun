//
//  TopUtil.h
//  sdk
//
//  Created by cenwenchu on 12-6-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

//Functions for Encoding Data.
@interface NSData (TOPEncode)
- (NSString *)MD5EncodedString;
- (NSData *)HMACSHA1EncodedDataWithKey:(NSString *)key;
- (NSString *)base64EncodedString;
@end

//Functions for Encoding String.
@interface NSString (TOPEncode)
- (NSString *)MD5EncodedString;
- (NSData *)HMACSHA1EncodedDataWithKey:(NSString *)key;
- (NSString *)base64EncodedString;
- (NSString *)URLEncodedString;
- (NSString *)URLEncodedStringWithCFStringEncoding:(CFStringEncoding)encoding;
@end




@interface TopUtil : NSObject

@end
