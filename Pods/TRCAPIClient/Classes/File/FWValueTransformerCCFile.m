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

#import "FWValueTransformerCCFile.h"
#import "CCFile.h"


@implementation FWValueTransformerCCFile
{
    CCFileKind *_fileKind;
}

+ (instancetype)transformerForFileKind:(CCFileKind *)fileKind
{
    FWValueTransformerCCFile *transformer = [FWValueTransformerCCFile new];
    transformer->_fileKind = fileKind;
    return transformer;
}

- (CCFile *)objectFromResponseValue:(NSString *)responseValue error:(NSError **)error
{
    if (responseValue.length > 0) {
        return [CCFile.alloc initWithUploadName:responseValue kind:_fileKind];
    } else {
        return nil;
    }
}

- (id)requestValueFromObject:(id)object error:(NSError **)error
{
    return nil;
}

- (TRCValueTransformerType)externalTypes
{
    return TRCValueTransformerTypeString;
}


@end
