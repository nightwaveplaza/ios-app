//
//  APIClient.m
//  InteractiveDisplay
//
//  Created by Aleksey Garbarev on 23/12/2018.
//  Copyright © 2018 Stellarsolvers. All rights reserved.
//

#import "CCAPIClient.h"
#import "TyphoonRestClient.h"
#import "CCAPIClient+Infrastructure.h"

@interface CCAPIClient()
@property (nonatomic, strong) TyphoonRestClient *restClient;

@property (nonatomic, strong) TRCConnectionNSURLSession *networkConnection;
@property (nonatomic, strong) TRCConnectionLogger *loggerConnection;

@property (nonatomic, strong) NSMutableArray<TRCConnectionProxy *> *middleConnections;

@end

@implementation CCAPIClient

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.restClient = [TyphoonRestClient new];
    
    self.restClient.querySerializationOptions = TRCSerializerHttpQueryOptionsIncludeArrayIndices;
    
    self.middleConnections = [NSMutableArray new];
        
    [self setupConnections];
    [self registerSelfRegisteredComponentsForClass:[self class]];
    [self registerSelfRegisteredComponentsForClass:[CCAPIClient class]];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Connections
//-------------------------------------------------------------------------------------------

- (void)setupConnections
{
    self.loggerConnection = [[TRCConnectionLogger alloc] init];

    _sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.networkConnection = [[TRCConnectionNSURLSession alloc] initWithBaseUrl:[self findBaseURL] configuration:_sessionConfiguration];
    
    [self updateConnectionsChain];
}

- (void)updateConnectionsChain
{
    NSMutableArray<TRCConnectionProxy *> *proxyConnections = [NSMutableArray new];
    
    [proxyConnections addObjectsFromArray:self.middleConnections];
    
    if (self.enableLogging) {
        [proxyConnections addObject:self.loggerConnection];
    }
    
    __block TRCConnectionProxy *previousConnection = nil;
    [proxyConnections enumerateObjectsWithOptions:0 usingBlock:^(TRCConnectionProxy *connection, NSUInteger idx, BOOL * _Nonnull stop) {
        if (previousConnection) {
            connection.connection = previousConnection;
        } else {
            connection.connection = self.networkConnection;
        }
        previousConnection = connection;
    }];
    
    if (proxyConnections.count > 0) {
        self.restClient.connection = [proxyConnections lastObject];
    } else {
        self.restClient.connection = self.networkConnection;
    }
}

- (void)setBaseUrl:(NSURL *)baseUrl
{
    self.networkConnection.baseUrl = baseUrl;
}

- (NSURL *)baseUrl
{
    return self.networkConnection.baseUrl;
}

- (void)setEnableLogging:(BOOL)enableLogging
{
    _enableLogging = enableLogging;
    [self updateConnectionsChain];
}

- (void)appendConnection:(id<TRCConnection>)connection
{
    [self.middleConnections addObject:connection];
    [self updateConnectionsChain];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Self Registered Components
//-------------------------------------------------------------------------------------------

+ (NSMutableDictionary<NSString *, NSMutableSet *> *)componentsRegistry
{
    static NSMutableDictionary<NSString *, NSMutableSet *> *selfRegisteredComponents;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        selfRegisteredComponents = [NSMutableDictionary new];
    });
    return selfRegisteredComponents;
}

+ (NSMutableSet *)componentsForClientClass
{
    NSString *key = NSStringFromClass(self);
    NSMutableDictionary *registry = [self componentsRegistry];
    NSMutableSet *set = registry[key];
    if (!set) {
        set = [NSMutableSet new];
        registry[key] = set;
    }
    return set;
}

+ (void)addSelfRegisteredComponentClass:(Class)clazz
{
    [[self componentsForClientClass] addObject:clazz];
}

- (void)registerSelfRegisteredComponentsForClass:(Class)clientClazz
{
    for (Class clazz in [clientClazz componentsForClientClass]) {
        [clazz registerWithAPIClient:self];
    }
}

//-------------------------------------------------------------------------------------------
#pragma mark - Private
//-------------------------------------------------------------------------------------------

- (NSURL *)findBaseURL
{
    NSArray *urls = [[self class] availableUrls];
    CCAPIClientURL *first = [urls firstObject];
    if (first.url != nil) {
        return first.url;
    }
    return [NSURL URLWithString:@""];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Class configuration (override in subclasses)
//-------------------------------------------------------------------------------------------

+ (NSArray<CCAPIClientURL *> *)availableUrls
{
    return @[ [CCAPIClientURL withUrl:@"" name:@"" description:@""] ];
}

+ (NSString *)name
{
    return @"";
}



@end
