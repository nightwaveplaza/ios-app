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

@interface CCUserDefaultsStorage : NSObject <CCSingletoneStorage>

@property (nonatomic, strong) NSUserDefaults *userDefaults; //Pass nil to use standardUserDefaults

- (instancetype)initWithClass:(Class)objectClass key:(NSString *)key;

+ (instancetype)withClass:(Class)objectClass key:(NSString *)key;

- (void)writeInstanceToDisk:(id)instance;

- (id)readInstanceFromDisk;

- (void)deleteInstanceFromDisk;

- (BOOL)hasStoredInstance;

@end
