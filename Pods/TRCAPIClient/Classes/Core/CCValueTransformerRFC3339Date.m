    ////////////////////////////////////////////////////////////////////////////////
//
//  APPS QUICKLY
//  Copyright 2015 Apps Quickly Pty Ltd
//  All Rights Reserved.
//
//  NOTICE: Prepared by AppsQuick.ly on behalf of Apps Quickly. This software
//  is proprietary information. Unauthorized use is prohibited.
//
////////////////////////////////////////////////////////////////////////////////

#import "CCValueTransformerRFC3339Date.h"
#import "TRCUtils.h"
#import "TyphoonRestClientErrors.h"
#import "CCAPIClient+Infrastructure.h"

@implementation CCValueTransformerRFC3339Date {
    NSISO8601DateFormatter *_formatter;
}

REGISTER_COMPONENT(CCAPIClient)

+ (void)registerWithAPIClient:(CCAPIClient *)apiClient
{
    [apiClient.restClient registerValueTransformer:[[CCValueTransformerRFC3339Date alloc] initWithFormat:NSISO8601DateFormatWithFullDate] forTag:@"{date}"];
    [apiClient.restClient registerValueTransformer:[[CCValueTransformerRFC3339Date alloc] initWithFormat:NSISO8601DateFormatWithFullTime] forTag:@"{time}"];
    [apiClient.restClient registerValueTransformer:[[CCValueTransformerRFC3339Date alloc] initWithFormat:NSISO8601DateFormatWithInternetDateTime] forTag:@"{date-time}"];
}

- (instancetype)initWithFormat:(NSISO8601DateFormatOptions)formatOption
{
    self = [super init];
    if (self) {
        _formatter = [NSISO8601DateFormatter new];
        _formatter.formatOptions = formatOption;
    }
    return self;
}

- (NSDate *)objectFromResponseValue:(NSString *)responseValue error:(NSError **)error
{
    if (![responseValue isKindOfClass:NSString.class]) {
        if (error) {
            *error = TRCErrorWithFormat(TyphoonRestClientErrorCodeRequestSerialization, @"Expected 'NSString' object, but got '%@'.", NSStringFromClass([responseValue class]));
        }
        return nil;
    }

    NSDate *date = [_formatter dateFromString:responseValue];
    if (!date && error) {
        *error = TRCErrorWithFormat(TyphoonRestClientErrorCodeResponseSerialization, @"Can't create NSDate from string '%@'", responseValue);
    }
    return date;
}

- (NSString *)requestValueFromObject:(id)object error:(NSError **)error
{
    if (![object isKindOfClass:NSDate.class]) {
        if (error) {
            *error = TRCErrorWithFormat(TyphoonRestClientErrorCodeRequestSerialization, @"Can't convert '%@' into NSString using %@", [object class], [self class]);
        }
        return nil;
    }

    NSString *string = [_formatter stringFromDate:object];

    if (!string && error) {
        *error = TRCErrorWithFormat(TyphoonRestClientErrorCodeRequestSerialization, @"Can't convert NSDate '%@' into NSString", object);
    }

    return string;
}

@end
