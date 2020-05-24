//
//  CCAPIClientURL.m
//  InteractiveDisplay
//
//  Created by Aleksey Garbarev on 24/12/2018.
//  Copyright © 2018 Stellarsolvers. All rights reserved.
//

#import "CCAPIClientURL.h"

@implementation CCAPIClientURL

+ (instancetype)withUrl:(nonnull NSString *)urlString name:(nullable NSString *)name description:(nullable NSString *)description
{
    CCAPIClientURL *url = [CCAPIClientURL new];
    url.url = [NSURL URLWithString:urlString];
    url.name = name;
    url.serverDescription = description;
    return url;
}

@end
