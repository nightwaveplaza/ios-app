//
//  APIClient.h
//  InteractiveDisplay
//
//  Created by Aleksey Garbarev on 23/12/2018.
//  Copyright © 2018 Stellarsolvers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TyphoonRestClient/TyphoonRestClient.h>
#import "CCAPIClientURL.h"

NS_ASSUME_NONNULL_BEGIN

@interface CCAPIClient : NSObject

@property (nonatomic, strong) NSURL *baseUrl;
@property (nonatomic) BOOL enableLogging;

@property (nonatomic, readonly) NSURLSessionConfiguration *sessionConfiguration;

- (void)appendConnection:(id<TRCConnection>)connection;

@end

NS_ASSUME_NONNULL_END
