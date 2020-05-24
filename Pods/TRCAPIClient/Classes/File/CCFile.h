////////////////////////////////////////////////////////////////////////////////
//
//  LOUDCLEAR
//  Copyright 2017 LoudClear Pty Ltd
//  All Rights Reserved.
//
//  NOTICE: Prepared by Loud & Clear on behalf of LoudClear. This software
//  is proprietary information. Unauthorized use is prohibited.
//
////////////////////////////////////////////////////////////////////////////////

#import <Foundation/Foundation.h>
#import <TyphoonRestClient/TRCSerializerMultipart.h>
#import "CCEnum.h"
#import <Photos/Photos.h>

#if TARGET_OS_IPHONE
  #import <UIKit/UIKit.h>
  #define Image UIImage
#else
  #import <Cocoa/Cocoa.h>
  #define Image NSImage
#endif

typedef NS_OPTIONS(NSUInteger, CCFileStates) {
    CCFileStatesHasLocalData  = 1 << 0,
    CCFileStatesHasRemoteData = 1 << 1
};

@interface CCFileKind : CCEnum
+ (instancetype)_photo;
+ (instancetype)_video;
+ (instancetype)_audio;
@end


@interface CCFile : NSObject

@property (nonatomic, readonly) CCFileStates states;
@property (nonatomic) CCFileKind *kind;

// Uploaded properties:
@property (nonatomic) NSString *uploadName;

// To upload properties:
@property (nonatomic) NSString *extension;
@property (nonatomic) NSString *mime;

- (instancetype)initWithQuickTimeMovieAtURL:(NSURL *)url thumbnail:(Image *)thumbnail;

- (instancetype)initWithImage:(Image *)image;

- (instancetype)initWithPHAsset:(PHAsset *)asset;

- (instancetype)initWithUploadName:(NSString *)name kind:(CCFileKind *)kind;

/// Same as initWithUploadName:imageUrl kind:CCFileKind._photo
- (instancetype)initWithImageUrl:(NSString *)imageUrl;

+ (instancetype)withImage:(Image *)image;

+ (instancetype)withImageUrl:(NSString *)imageUrl;

//-------------------------------------------------------------------------------------------
#pragma mark - Upload
//-------------------------------------------------------------------------------------------

/**
 * Returns one of data or filePath
 * */
- (void)getUploadDataWithCompletion:(void(^)(NSData *data, NSString *filePath))completion;


- (void)getUploadMultipartFileWithCompletion:(void(^)(TRCMultipartFile *multipartFile))completion;

//-------------------------------------------------------------------------------------------
#pragma mark - Thumbnail
//-------------------------------------------------------------------------------------------

- (void)getLocalThumbnailImage:(void(^)(Image *thumbnail))completion;

@end
