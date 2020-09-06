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

#import "EXTScope.h"
#import "CCLogger.h"
#import "CCSingleton.h"
#import "CCWarningMute.h"
#import "CCProperty.h"

#define let __auto_type const
#define var __auto_type

#define CCSafeCall(block, ...) if((block)) { (block)(__VA_ARGS__); }
#define CCSafeCallOnMain(block, ...) if((block)) { dispatch_async(dispatch_get_main_queue(), ^{ (block)(__VA_ARGS__); }); }
#define CCSafeCallOnMainAfter(seconds, block, ...) if((block)) { dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)( seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{(block)(__VA_ARGS__);});}
#define CCSafeCallOn(queue, block, ...) if((block)) { dispatch_async(queue, ^{ (block)(__VA_ARGS__); }); }

#define CCSelectorToString(sel) NSStringFromSelector(@selector(sel))

#define CCQueueMain dispatch_get_main_queue()
#define CCQueueHigh dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)
#define CCQueueDefault dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
#define CCQueueLow dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)
#define CCQueueBackground dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)

#define CCSetAssociatedObject(key, value) objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
#define CCGetAssociatedObject(key) objc_getAssociatedObject(self, key)

#define CCSetAssociatedObjectToObject(object, key, value) objc_setAssociatedObject(object, key, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
#define CCGetAssociatedObjectFromObject(object, key) objc_getAssociatedObject(object, key)

#define CCNSValueFromPrimitive(primitive) ([NSValue value:&primitive withObjCType:@encode(typeof(primitive))])

#define CCCMTime(seconds) CMTimeMakeWithSeconds(seconds, NSEC_PER_SEC)

#define CCIOSVersionGreaterThan(version)           ([UIDevice.currentDevice.systemVersion compare:@ #version options:NSNumericSearch] == NSOrderedDescending)
#define CCIOSVersionGreaterThanOrEqualTo(version)  ([UIDevice.currentDevice.systemVersion compare:@ #version options:NSNumericSearch] != NSOrderedAscending)
#define CCIOSVersionLessThan(version)              ([UIDevice.currentDevice.systemVersion compare:@ #version options:NSNumericSearch] == NSOrderedAscending)
#define CCIOSVersionLessThanOrEqualTo(version)     ([UIDevice.currentDevice.systemVersion compare:@ #version options:NSNumericSearch] != NSOrderedDescending)

#define CCSetPointer(pointer, ...) if ((pointer)) {*pointer = __VA_ARGS__;}

// Deprecated:
#define CMTime(seconds) CMTimeMakeWithSeconds(seconds, NSEC_PER_SEC) __deprecated_msg("Use `CCCMTime` instead.");
#define RadiansToDegrees(radians) (CGFloat) ((radians) * (180.0 / M_PI)) __deprecated_msg("Use `CCRadiansToDegrees` from `Math` component instead.");
#define DegreesToRadians(degrees) (CGFloat) ((degrees) / 180.0 * M_PI) __deprecated_msg("Use `CCDegreesToRadians` from `Math` component instead.");


// To be deprecated:
#define SafetyCall(block, ...) if((block)) { (block)(__VA_ARGS__); } // __deprecated_msg("Use `CCSafeCall` instead.");
#define SafetyCallAfter(seconds, block, ...) if((block)) { dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)( seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{(block)(__VA_ARGS__);});}  // __deprecated_msg("Use `CCSafeCallOnMainAfter` instead.");
#define SafetyCallOn(queue, block, ...) if((block)) { dispatch_async(queue, ^{ (block)(__VA_ARGS__); }); }  // __deprecated_msg("Use `CCSafeCallOn` instead.");
#define SafetyCallOnMain(block, ...) if((block)) { dispatch_async(dispatch_get_main_queue(), ^{ (block)(__VA_ARGS__); }); }  // __deprecated_msg("Use `CCSafeCallOnMain` instead.");
#define MainQueue dispatch_get_main_queue()  // __deprecated_msg("Use `CCQueueMain` instead.");
#define QueueHigh dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)  // __deprecated_msg("Use `CCQueueHigh` instead.");
#define QueueDefault dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)  // __deprecated_msg("Use `CCQueueDefault` instead.");
#define QueueLow dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)  // __deprecated_msg("Use `CCQueueLow` instead.");
#define QueueBackground dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)  // __deprecated_msg("Use `CCQueueBackground` instead.");
#define SetAssociatedObject(key, value) objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);  // __deprecated_msg("Use `CCSetAssociatedObject` instead.");
#define GetAssociatedObject(key) objc_getAssociatedObject(self, key)  // __deprecated_msg("Use `CCGetAssociatedObject` instead.");
#define SetAssociatedObjectToObject(object, key, value) objc_setAssociatedObject(object, key, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);  // __deprecated_msg("Use `CCSetAssociatedObjectToObject` instead.");
#define GetAssociatedObjectFromObject(object, key) objc_getAssociatedObject(object, key)  // __deprecated_msg("Use `CCGetAssociatedObjectToObject` instead.");
#define NSValueFromPrimitive(primitive) ([NSValue value:&primitive withObjCType:@encode(typeof(primitive))])  // __deprecated_msg("Use `CCNSValueFromPrimitive` instead.");
