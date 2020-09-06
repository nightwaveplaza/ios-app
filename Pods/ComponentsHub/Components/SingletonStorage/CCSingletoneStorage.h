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


@protocol CCSingletoneStorage <NSObject>

- (id)getObject;

- (void)saveObject:(id)object;

/** Returns YES, if object was changed */
- (BOOL)saveCurrentObject;

@end
