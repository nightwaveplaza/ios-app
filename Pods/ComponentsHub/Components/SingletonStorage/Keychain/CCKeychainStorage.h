////////////////////////////////////////////////////////////////////////////////
//
//  FANHUB
//  Copyright 2016 FanHub Pty Ltd
//  All Rights Reserved.
//
//  NOTICE: Prepared by AppsQuick.ly on behalf of FanHub. This software
//  is proprietary information. Unauthorized use is prohibited.
//
////////////////////////////////////////////////////////////////////////////////

#import "CCSingletoneStorage.h"


@interface CCKeychainStorage : NSObject <CCSingletoneStorage>

- (instancetype)initWithClass:(Class)objectClass accountName:(NSString *)account serviceName:(NSString *)service;

- (BOOL)hasKeychainAccount;

- (void)deleteInstanceFromKeychain;

- (void)saveToKeychainInstance:(id)instance;

- (id)loadInstanceFromKeychain;

@end
