//
//  CCLogger.h
//  iOS Hub
//
//  Created by Aleksey Garbarev on 19/11/2016.
//  Copyright © 2016 Loud & Clear. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 * You may add the following to your Podfile to change default log level for CoreComponents:
 * (change CCLOGGER_LEVEL_INFO to appropriate level)
 *
 *  post_install do |installer|
 *    installer.pods_project.targets.each do |target|
 *      target.build_configurations.each do |config|
 *        config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= ['$(inherited)']
 *        config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] << 'CCLOGGER_LEVEL_INFO'
 *      end
 *    end
 *  end
 */

#ifndef DDLogInfo

#define LOG_ASYNC_ENABLED YES

#define DDLogFlagError     (1 << 0)
#define DDLogFlagWarning   (1 << 1)
#define DDLogFlagInfo      (1 << 2)
#define DDLogFlagDebug     (1 << 3)
#define DDLogFlagVerbose   (1 << 4)

#define DDLogLevelOff       0
#define DDLogLevelError     (DDLogFlagError)
#define DDLogLevelWarning   (DDLogLevelError   | DDLogFlagWarning)
#define DDLogLevelInfo      (DDLogLevelWarning | DDLogFlagInfo)
#define DDLogLevelDebug     (DDLogLevelInfo    | DDLogFlagDebug)
#define DDLogLevelVerbose   (DDLogLevelDebug   | DDLogFlagVerbose)
#define DDLogLevelAll       NSUIntegerMax

#ifdef DEBUG
#   ifdef CCLOGGER_LEVEL_ERROR
#       define LOG_LEVEL_DEF DDLogLevelError
#   elif defined(CCLOGGER_LEVEL_WARNING)
#       define LOG_LEVEL_DEF DDLogLevelWarning
#   elif defined(CCLOGGER_LEVEL_INFO)
#       define LOG_LEVEL_DEF DDLogLevelInfo
#   endif
#endif

#ifndef LOG_LEVEL_DEF
#   define LOG_LEVEL_DEF DDLogLevelInfo 
#endif

#define LOG_MACRO(isAsynchronous, lvl, flg, ctx, atag, fnct, frmt, ...) \
        [CCLogger log : isAsynchronous                                     \
                level : lvl                                                \
                 flag : flg                                                \
              context : ctx                                                \
                 file : __FILE__                                           \
             function : fnct                                               \
                 line : __LINE__                                           \
                  tag : atag                                               \
               format : (frmt), ## __VA_ARGS__]

#define LOG_MAYBE(async, lvl, flg, ctx, tag, fnct, frmt, ...) \
do { if(lvl & flg) LOG_MACRO(async, lvl, flg, ctx, tag, fnct, frmt, ##__VA_ARGS__); } while(0)

#define DDLogError(frmt, ...)   LOG_MAYBE(NO,                LOG_LEVEL_DEF, DDLogFlagError,   0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define DDLogWarn(frmt, ...)    LOG_MAYBE(LOG_ASYNC_ENABLED, LOG_LEVEL_DEF, DDLogFlagWarning, 0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define DDLogInfo(frmt, ...)    LOG_MAYBE(LOG_ASYNC_ENABLED, LOG_LEVEL_DEF, DDLogFlagInfo,    0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define DDLogDebug(frmt, ...)   LOG_MAYBE(LOG_ASYNC_ENABLED, LOG_LEVEL_DEF, DDLogFlagDebug,   0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define DDLogVerbose(frmt, ...) LOG_MAYBE(LOG_ASYNC_ENABLED, LOG_LEVEL_DEF, DDLogFlagVerbose, 0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)

#endif

@interface CCLogger : NSObject

+ (void)log:(BOOL)asynchronous
      level:(NSUInteger)level
       flag:(NSUInteger)flag
    context:(NSInteger)context
       file:(const char *)file
   function:(const char *)function
       line:(NSUInteger)line
        tag:(id)tag
     format:(NSString *)format, ... NS_FORMAT_FUNCTION(9, 10);

@end
