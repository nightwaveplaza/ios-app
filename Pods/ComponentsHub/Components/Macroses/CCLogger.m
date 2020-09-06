//
//  CCLogger.m
//  iOS Hub
//
//  Created by Aleksey Garbarev on 19/11/2016.
//  Copyright © 2016 Loud & Clear. All rights reserved.
//

#import "CCLogger.h"

@protocol CCLumberjackClass <NSObject>

- (void)log:(BOOL)asynchronous
    message:(NSString *)message
      level:(NSUInteger)level
       flag:(NSUInteger)flag
    context:(NSInteger)context
       file:(const char *)file
   function:(const char *)function
       line:(NSUInteger)line
        tag:(id)tag;

@end

@implementation CCLogger

+ (void)log:(BOOL)asynchronous
      level:(NSUInteger)level
       flag:(NSUInteger)flag
    context:(NSInteger)context
       file:(const char *)file
   function:(const char *)function
       line:(NSUInteger)line
        tag:(id)tag
     format:(NSString *)format, ... {
    va_list args;
    
    if (format) {
        va_start(args, format);
        NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
        va_end(args);

        if ([self hasCocoalumberjack]) {
            [[self lumberjack] log:asynchronous
                           message:message
                             level:level
                              flag:flag
                           context:context
                              file:file
                          function:function
                              line:line
                               tag:tag];
        } else {
            NSString *levelTag = [self levelTagFromLevel:level];
            NSLog(@"%@%@", levelTag, message);
        }
        
    }
}

+ (NSString *)levelTagFromLevel:(NSUInteger)level
{
    switch (level) {
        case DDLogFlagError: return @"[E]: ";
        case DDLogFlagInfo: return @"[I]: ";
        case DDLogFlagDebug: return @"[D]: ";
        case DDLogFlagWarning: return @"[W]: ";
        case DDLogFlagVerbose: return @"[V]: ";
    }
    return @"";
}

+ (BOOL)hasCocoalumberjack
{
    return NSClassFromString(@"DDLog") != nil;
}

+ (id<CCLumberjackClass>)lumberjack
{
    return (id)NSClassFromString(@"DDLog");
}

@end
