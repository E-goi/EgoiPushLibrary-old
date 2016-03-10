//
//  NSString+HTML.h
//  GoiMeUp
//
//  Created by Miguel Chaves on 16/01/15.
//  Copyright (c) 2015 E-Goi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (HTML)

- (NSString *)decodeHTMLCharacterEntities;

- (NSString *)encodeHTMLCharacterEntities;

@end
