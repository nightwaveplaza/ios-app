//
//  CCEnum.m
//  Fernwood
//
//  Created by Aleksey Garbarev on 09/03/2018.
//  Copyright © 2018 Loud & Clear Pty Ltd. All rights reserved.
//

#import "CCEnum.h"

@implementation CCEnum {
    id _value;
}

- (instancetype _Nonnull)initWithValue:(id _Nonnull)value
{
    self = [super init];
    if (self) {
        _value = value;
    }
    return self;
}

+ (id _Nullable)valueFromResponseValue:(id _Nullable)value
{
    if ([value isKindOfClass:NSArray.class]) {
        NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:[value count]];
        for (id object in value) {
            [result addObject:[self fromResponseValue:object]];
        }
        return result;
        
    } else {
        return [self fromResponseValue:value];
    }
}

+ (id _Nullable)requestValueFromValue:(id _Nullable)value
{
    if ([value isKindOfClass:NSArray.class]) {
        NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:[value count]];
        for (id object in value) {
            NSAssert([object isKindOfClass:CCEnum.class], @"Can't create request value from %@", value);
            [result addObject:[object requestValue]];
        }
        return result;
    } else if ([value isKindOfClass:CCEnum.class]) {
        return [value requestValue];
    }
    
    return [NSNull null];
}

- (id)requestValue
{
    return _value;
}

+ (instancetype)fromStringValue:(NSString *_Nullable)string
{
    return [self fromResponseValue:string];
}


- (NSString *)stringValue
{
    return [_value description];
}

- (NSArray *)allOptions
{
    return @[];
}

+ (instancetype _Nullable)fromResponseValue:(id)value
{
    NSAssert(NO, @"%@ should be implemented in subclass", NSStringFromSelector(_cmd));
    return nil;
}

+ (NSArray *_Nonnull)allOptions
{
    NSAssert(NO, @"%@ should be implemented in subclass", NSStringFromSelector(_cmd));
    return @[];
}

- (BOOL)isEqual:(NSObject *)other
{
    if (other == self)
        return YES;
    if (!other || ![other.class isEqual:self.class])
        return NO;
    
    return [self isEqualToAnEnum:(id)other];
}

- (BOOL)isEqualToAnEnum:(CCEnum *)anEnum
{
    if (self == anEnum)
        return YES;
    if (anEnum == nil)
        return NO;
    if (_value != anEnum->_value && ![_value isEqual:anEnum->_value])
        return NO;
    return YES;
}

- (NSUInteger)hash
{
    return [_value hash];
}

- (NSString *)description
{
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: %@", NSStringFromClass([self class]), _value];
    [description appendString:@">"];
    return description;
}

- (id)copyWithZone:(nullable NSZone *)zone
{
    return self;
}

+ (NSArray *)fastCodingKeys
{
    return @[@"_value"];
}

- (id)awakeAfterFastCoding
{
    return [self.class fromResponseValue:_value];
}

- (NSUInteger)index
{
    return [[self.class allOptions] indexOfObject:self];
}

@end
