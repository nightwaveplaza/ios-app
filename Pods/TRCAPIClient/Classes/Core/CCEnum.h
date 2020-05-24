//
//  CCEnum.h
//  Fernwood
//
//  Created by Aleksey Garbarev on 09/03/2018.
//  Copyright © 2018 Loud & Clear Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCEnum : NSObject <NSCopying>

//-------------------------------------------------------------------------------------------
#pragma mark - Request / Response values
//-------------------------------------------------------------------------------------------

+ (instancetype _Nullable)fromResponseValue:(id _Nullable)value;

- (id _Nonnull)requestValue;

+ (id _Nullable)requestValueFromValue:(id _Nullable)value;

+ (id _Nullable)valueFromResponseValue:(id _Nullable)value;

//-------------------------------------------------------------------------------------------
#pragma mark - String
//-------------------------------------------------------------------------------------------

+ (instancetype _Nullable)fromStringValue:(NSString *_Nullable)string;

- (NSString *_Nonnull)stringValue;

/**
 * Array of all possible CCEnum instances for given class
 * */
+ (NSArray *_Nonnull)allOptions;

- (NSUInteger)index;

@end
