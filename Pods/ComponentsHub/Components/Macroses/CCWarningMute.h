////////////////////////////////////////////////////////////////////////////////
//
//  iOS Hub
//  Created by ivan at 17.10.2017.
//
//  Copyright 2017 Loud & Clear Pty Ltd
//  All Rights Reserved.
//
////////////////////////////////////////////////////////////////////////////////

#define _CC_WARNING_MUTE_HELPER_0(x) #x
#define _CC_WARNING_MUTE_HELPER_1(x) _CC_WARNING_MUTE_HELPER_0(clang diagnostic ignored x)
#define _CC_WARNING_MUTE_HELPER_2(x) _CC_WARNING_MUTE_HELPER_1("-W" #x)
#define _CC_WARNING_MUTE_HELPER_3(x) _Pragma(_CC_WARNING_MUTE_HELPER_2(x))

#define CC_WARNING_MUTE(x) \
    _Pragma("clang diagnostic push") \
    _CC_WARNING_MUTE_HELPER_3(x)

#define CC_WARNING_MUTE_END \
    _Pragma("clang diagnostic pop")

#define CC_WARNING_MUTE_ARC_RETAIN_CYCLES              CC_WARNING_MUTE(arc-retain-cycles)
#define CC_WARNING_MUTE_MISMATCHED_PARAMETER_TYPES     CC_WARNING_MUTE(mismatched-parameter-types)
#define CC_WARNING_MUTE_STRICT_PROTOTYPES              CC_WARNING_MUTE(strict-prototypes)
#define CC_WARNING_MUTE_PERFORM_SELECTOR_LEAKS         CC_WARNING_MUTE(arc-performSelector-leaks)
#define CC_WARNING_MUTE_INCOMPATIBLE_PROPERTY_TYPE     CC_WARNING_MUTE(incompatible-property-type)
#define CC_WARNING_MUTE_DEPRECATED_DECLARATIONS        CC_WARNING_MUTE(deprecated-declarations)





// To be deprecated:
#define SUPPRESS_WARNING(x) \
    _Pragma("clang diagnostic push") \
    _CC_WARNING_MUTE_HELPER_3(x)

#define SUPPRESS_WARNING_END \
    _Pragma("clang diagnostic pop")

#define SUPPRESS_WARNING_ARC_RETAIN_CYCLES              SUPPRESS_WARNING(arc-retain-cycles)
#define SUPPRESS_WARNING_MISMATCHED_PARAMETER_TYPES     SUPPRESS_WARNING(mismatched-parameter-types)
#define SUPPRESS_WARNING_STRICT_PROTOTYPES              SUPPRESS_WARNING(strict-prototypes)
#define SUPPRESS_WARNING_PERFORM_SELECTOR_LEAKS         SUPPRESS_WARNING(arc-performSelector-leaks)
#define SUPPRESS_WARNING_INCOMPATIBLE_PROPERTY_TYPE     SUPPRESS_WARNING(incompatible-property-type)
#define SUPPRESS_WARNING_DEPRECATED_DECLARATIONS        SUPPRESS_WARNING(deprecated-declarations)

