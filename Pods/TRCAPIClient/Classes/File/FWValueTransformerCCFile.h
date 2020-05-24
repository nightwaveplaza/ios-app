////////////////////////////////////////////////////////////////////////////////
//
//  LOUD & CLEAR PTY LTD
//  Copyright 2018 Loud & Clear Pty Ltd Pty Ltd
//  All Rights Reserved.
//
//  NOTICE: Prepared by Loud & Clear on behalf of Loud & Clear Pty Ltd. This software
//  is proprietary information. Unauthorized use is prohibited.
//
////////////////////////////////////////////////////////////////////////////////

#import <Foundation/Foundation.h>
#import <TyphoonRestClient/TRCValueTransformer.h>
#import "CCFile.h"


@interface FWValueTransformerCCFile : NSObject <TRCValueTransformer>

+ (instancetype)transformerForFileKind:(CCFileKind *)fileKind;

@end
