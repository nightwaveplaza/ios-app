//
//  CCAPIClientURL.h
//  InteractiveDisplay
//
//  Created by Aleksey Garbarev on 24/12/2018.
//  Copyright © 2018 Stellarsolvers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCAPIClientURL : NSObject

@property (nonatomic, nonnull,strong) NSURL *url;
@property (nonatomic, nullable, strong) NSString *name;
@property (nonatomic, nullable, strong) NSString *serverDescription;

+ (instancetype)withUrl:(nonnull NSString *)urlString name:(nullable NSString *)name description:(nullable NSString *)description;

@end

