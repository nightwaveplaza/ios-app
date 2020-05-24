//
//  CCAPIClient+Subclasses.h
//  InteractiveDisplay
//
//  Created by Aleksey Garbarev on 24/12/2018.
//  Copyright © 2018 Stellarsolvers. All rights reserved.
//

#import "CCAPIClient.h"
#import <TyphoonRestClient/TyphoonRestClient.h>


#define REGISTER_COMPONENT(Client) + (void)load { [NSClassFromString(@#Client) addSelfRegisteredComponentClass:self]; }


NS_ASSUME_NONNULL_BEGIN

@interface CCAPIClient (Subclasses)

@property (nonatomic, strong, readonly) TyphoonRestClient *restClient;

+ (NSString *)name;
+ (NSArray<CCAPIClientURL *> *)availableUrls;

+ (void)addSelfRegisteredComponentClass:(Class)clazz;

@end


@protocol CCTRCSelfRegisteredComponent <NSObject>

+ (void)registerWithAPIClient:(CCAPIClient *)client;

@end

NS_ASSUME_NONNULL_END
