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

#import <SAMKeychain/SAMKeychain.h>
#import <FastCoding/FastCoder.h>
#import "CCKeychainStorage.h"
#import "CCMacroses.h"

@implementation CCKeychainStorage
{
    NSString *_service;
    NSString *_account;
    Class _objectClass;

    id _instance;
}

- (instancetype)initWithClass:(Class)objectClass accountName:(NSString *)account serviceName:(NSString *)service
{
    self = [super init];
    if (self) {
        _objectClass = objectClass;
        _service = service;
        _account = account;
    }
    return self;
}

//-------------------------------------------------------------------------------------------
#pragma mark - CCSingletoneStorage methods
//-------------------------------------------------------------------------------------------

- (void)saveObject:(id)object
{
    NSAssert(!object || [object isKindOfClass:_objectClass], @"Object %@ is not kind of %@", object, _objectClass);

    if (object == nil) {
        if ([self hasKeychainAccount]) {
            [self deleteInstanceFromKeychain];
        }
    }
    else {
        [self saveToKeychainInstance:object];
    }

    _instance = object;
}

- (id)getObject
{
    if (_instance == nil)
    {
        if (![self hasKeychainAccount]) {
            // No accounts in keychain.
            return nil;
        }

        _instance = [self loadInstanceFromKeychain];
        if (_instance == nil) {
            DDLogInfo(@"Can't load %@ - deleting in case it corrupted.", _objectClass);
            [self saveObject:nil];
        }
    }
    return _instance;
}

- (BOOL)saveCurrentObject
{
    BOOL hasChanges = _instance && ![_instance isEqual:[self loadInstanceFromKeychain]];
    if (hasChanges) {
        [self saveToKeychainInstance:_instance];
    }
    return hasChanges;
}

//-------------------------------------------------------------------------------------------
#pragma mark - Instance methods
//-------------------------------------------------------------------------------------------

- (BOOL)hasKeychainAccount
{
    return [[SAMKeychain accountsForService:_service] count] != 0;
}

- (void)deleteInstanceFromKeychain
{
    SAMKeychainQuery *keyChainQuery = [self instanceKeychainQuery];

    NSError *error = nil;
    if (![keyChainQuery deleteItem:&error]) {
        DDLogWarn(@"Can't delete %@ from keychain: %@", _instance, error);
    } else {
        DDLogInfo(@"Deleted %@ from keychain.", _instance);
    }
}

- (void)saveToKeychainInstance:(id)instance
{
    NSData *instanceData = [FastCoder dataWithRootObject:instance];

    SAMKeychainQuery *keyChainQuery = [self instanceKeychainQuery];
    keyChainQuery.passwordObject = instanceData;

    NSError *error = nil;
    if (![keyChainQuery save:&error]) {
        DDLogError(@"Can't save %@ to keychain: %@", _objectClass, error);
    } else {
        DDLogInfo(@"Saved %@ to keychain.", _objectClass);
    }
}

- (id)loadInstanceFromKeychain
{
    SAMKeychainQuery *keyChainQuery = [self instanceKeychainQuery];
    NSError *error = nil;

    if (![keyChainQuery fetch:&error]) {
        DDLogInfo(@"Can't load %@ from keychain: %@", _objectClass, error);
        return nil;
    }
    else {
        id instance = [FastCoder objectWithData:(id)keyChainQuery.passwordObject];

        if ([instance isKindOfClass:_objectClass]) {
            DDLogInfo(@"Loaded %@ from keychain.", _objectClass);
            return instance;
        } else {
            DDLogInfo(@"Can't decode %@ loaded from keychain.", _objectClass);
            return nil;
        }
    }
}

//-------------------------------------------------------------------------------------------
#pragma mark - Private
//-------------------------------------------------------------------------------------------

- (SAMKeychainQuery *)instanceKeychainQuery
{
    SAMKeychainQuery *keyChainQuery = [SAMKeychainQuery new];
    keyChainQuery.service = _service;
    keyChainQuery.account = _account;
    return keyChainQuery;
}

@end
