////////////////////////////////////////////////////////////////////////////////
//
//  iOS Hub
//  Created by ivan at 20.11.2017.
//
//  Copyright 2017 Loud & Clear Pty Ltd
//  All Rights Reserved.
//
////////////////////////////////////////////////////////////////////////////////

#define CC_IMPLEMENT_SHARED_SINGLETON(className) \
    static className *instance; \
    static dispatch_once_t onceToken; \
    dispatch_once(&onceToken, ^{ \
        instance = [className new]; \
    }); \
    return instance;
