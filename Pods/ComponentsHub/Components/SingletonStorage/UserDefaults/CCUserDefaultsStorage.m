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

#import <FastCoding/FastCoder.h>
#import "CCUserDefaultsStorage.h"
#import "CCMacroses.h"

@implementation CCUserDefaultsStorage
{
    Class _objectClass;
    NSString *_key;

    id _instance;
}

//-------------------------------------------------------------------------------------------
#pragma mark - Initialization
//-------------------------------------------------------------------------------------------

- (instancetype)initWithClass:(Class)objectClass key:(NSString *)key
{
    self = [super init];
    if (self) {
        _key = key;
        _objectClass = objectClass;
    }
    return self;
}

+ (instancetype)withClass:(Class)objectClass key:(NSString *)key
{
    return [[self alloc] initWithClass:objectClass key:key];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Singletone Storage
//-------------------------------------------------------------------------------------------

- (id)getObject
{
    if (_instance == nil)
    {
        if (![self hasStoredInstance]) {
            return nil;
        }

        _instance = [self readInstanceFromDisk];
        if (_instance == nil) {
            DDLogInfo(@"Can't load %@ - deleting in case it corrupted.", _objectClass);
            [self saveObject:nil];
        }
    }

    return _instance;
}

- (void)saveObject:(id)object
{
    NSAssert(!object || [object isKindOfClass:_objectClass], @"Object %@ is not kind of %@", object, _objectClass);

    if (object == nil) {
        if ([self hasStoredInstance]) {
            [self deleteInstanceFromDisk];
        }
    }
    else {
        [self writeInstanceToDisk:object];
    }

    _instance = object;
}

- (BOOL)saveCurrentObject
{
    BOOL hasChanges = _instance && ![_instance isEqual:[self readInstanceFromDisk]];
    if (hasChanges) {
        [self writeInstanceToDisk:_instance];
    }
    return hasChanges;
}

//-------------------------------------------------------------------------------------------
#pragma mark - Instance Methods
//-------------------------------------------------------------------------------------------

- (NSUserDefaults *)userDefaults
{
    if (!_userDefaults) {
        return [NSUserDefaults standardUserDefaults];
    }
    return _userDefaults;
}

- (void)writeInstanceToDisk:(id)instance
{
    NSData *data = [FastCoder dataWithRootObject:instance];
    if (data) {
        [self.userDefaults setObject:data forKey:_key];
        [self.userDefaults synchronize];
        DDLogInfo(@"Saved %@ to disk as '%@'.", _objectClass, _key);
    } else {
        DDLogError(@"Failed to save %@ to disk as '%@'", _objectClass, _key);
    }
}

- (id)readInstanceFromDisk
{
    NSData *data = [self.userDefaults objectForKey:_key];

    id instance = nil;

    if (![data isKindOfClass:[NSData class]]) {
        if ([data isKindOfClass:_objectClass]) {
            //Occurs, after we migrate direct NSUserDefaults save to CCUserDefaultsStorage.
            return data;
        } else {
            DDLogInfo(@"Failed to decode %@ from '%@'", _objectClass, _key);
            return nil;
        }
    }

    instance = [FastCoder objectWithData:data];

    if (![instance isKindOfClass:_objectClass]) {
        DDLogInfo(@"Failed to decode %@ from '%@'", _objectClass, _key);
        return nil;
    }

    if (instance) {
        DDLogInfo(@"Read %@ from disk as '%@'.", _objectClass, _key);
    }

    return instance;
}

- (void)deleteInstanceFromDisk
{
    [self.userDefaults removeObjectForKey:_key];
    [self.userDefaults synchronize];

    DDLogInfo(@"Deleted %@ as '%@' from disk.", _objectClass, _key);
}

- (BOOL)hasStoredInstance
{
    return [self.userDefaults objectForKey:_key] != nil;
}


@end
