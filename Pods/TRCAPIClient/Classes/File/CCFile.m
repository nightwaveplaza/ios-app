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

#import "CCFile.h"

#define SafetyCall(block, ...) if((block)) { (block)(__VA_ARGS__); }


@interface CCEnum (Private)
- (instancetype _Nonnull)initWithValue:(id _Nonnull)value;
@end


@interface CCFile()

@property (nonatomic) NSString *filePath;
@property (nonatomic) Image *originalImage;

@property (nonatomic) PHAsset *libraryAsset;

@property (nonatomic) Image *thumbnail;

@end

NSString *CCFileKindPhoto = @"x-image-name";
NSString *CCFileKindVideo = @"x-video-name";
NSString *CCFileKindAudio = @"x-audio-name";

@implementation CCFileKind
static NSDictionary *CCFileKindValues;
+ (void)load
{
    CCFileKindValues = @{
            @"x-image-name" : [CCFileKind.alloc initWithValue:@"x-image-name"],
            @"x-video-name" : [CCFileKind.alloc initWithValue:@"x-video-name"],
            @"x-audio-name" : [CCFileKind.alloc initWithValue:@"x-audio-name"],
    };
}
+ (instancetype)_photo
{
    return CCFileKindValues[@"x-image-name"];
}
+ (instancetype)_video
{
    return CCFileKindValues[@"x-video-name"];
}
+ (instancetype)_audio
{
    return CCFileKindValues[@"x-audio-name"];
}
+ (NSArray *)allOptions
{
    return [CCFileKindValues allValues];
}
+ (instancetype _Nullable)fromResponseValue:(id _Nullable)value
{
    return value ? CCFileKindValues[value] : nil;
}
@end



@implementation CCFile

//-------------------------------------------------------------------------------------------
#pragma mark - Interface methods
//-------------------------------------------------------------------------------------------

- (instancetype)initWithQuickTimeMovieAtURL:(NSURL *)url thumbnail:(Image *)thumbnail
{
    self = [super init];
    if (self) {
        self.filePath = url.path;
        self.thumbnail = thumbnail;
        self.extension = @"mov";
        self.mime = @"video/quicktime";
        self.kind = CCFileKind._video;
    }
    return self;
}

- (instancetype)initWithImage:(Image *)image
{
    self = [super init];
    if (self) {
        self.originalImage = image;
        self.extension = @"jpg";
        self.mime = @"image/jpeg";
        self.kind = CCFileKind._photo;
    }
    return self;
}

- (instancetype)initWithPHAsset:(PHAsset *)asset
{
    self = [super init];
    if (self) {
        self.libraryAsset = asset;
        self.extension = @"jpg";
        self.mime = @"image/jpeg";
        self.kind = CCFileKind._photo;
    }
    return self;
}

- (instancetype)initWithUploadName:(NSString *)name kind:(CCFileKind *)kind
{
    self = [super init];
    if (self) {
        self.uploadName = name;
        self.kind = kind;
    }
    return self;
}

- (instancetype)initWithImageUrl:(NSString *)imageUrl
{
    return [self initWithUploadName:imageUrl kind:CCFileKind._photo];
}

+ (instancetype)withImage:(Image *)image
{
    return [self.alloc initWithImage:image];
}

+ (instancetype)withImageUrl:(NSString *)imageUrl
{
    return [self.alloc initWithImageUrl:imageUrl];
}

- (NSString *)description
{
    NSString *states;
    if (self.states == (CCFileStatesHasLocalData | CCFileStatesHasRemoteData)) {
        states = @"local and remote";
    } else {
        states = (self.states & CCFileStatesHasRemoteData) ? @"remote" : @"local";
    }


    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@"self.states=%@", states];
    [description appendFormat:@", self.kind=%@", self.kind];
    [description appendFormat:@", self.uploadName=%@", self.uploadName];
    [description appendFormat:@", self.extension=%@", self.extension];
    [description appendFormat:@", self.mime=%@", self.mime];
    [description appendFormat:@", self.filePath=%@", self.filePath];
    [description appendFormat:@", self.originalImage=%@", self.originalImage];
    [description appendString:@">"];
    return description;
}

- (CCFileStates)states
{
    CCFileStates result = (CCFileStates)0;

    if (self.uploadName) {
        result |= CCFileStatesHasRemoteData;
    }

    if (self.originalImage || self.libraryAsset || self.filePath) {
        result |= CCFileStatesHasLocalData;
    }

    return result;
}

//-------------------------------------------------------------------------------------------
#pragma mark - Upload
//-------------------------------------------------------------------------------------------

- (void)getUploadDataWithCompletion:(void(^)(NSData *data, NSString *filePath))completion
{
    if (self.filePath) {
        SafetyCall(completion, nil, self.filePath);
    } else if (self.originalImage) {
        NSData *dataForUpload = [self dataFromImage:self.originalImage];
        SafetyCall(completion, dataForUpload, nil);
    } else if (self.libraryAsset) {
        [self render:self.libraryAsset fast:NO size:CGSizeMake(2560, 2560) completion:^(Image *image, NSError *error) {
            NSData *imageData = [self dataFromImage:image];
            SafetyCall(completion, imageData, nil);
        }];
    }
}

- (void)getUploadMultipartFileWithCompletion:(void (^)(TRCMultipartFile *multipartFile))completion
{
    [self getUploadDataWithCompletion:^(NSData *data, NSString *filePath) {
        TRCMultipartFile *file = TRCMultipartFile.new;
        file.mimeType = self.mime;
        file.filename = [@"upload" stringByAppendingPathExtension:self.extension];
        if (data) {
            file.data = data;
        } else {
            file.data = [NSData dataWithContentsOfFile:filePath];
            NSAssert(file.data, @"Can't load data from path: %@", filePath);
        }
        SafetyCall(completion, file);
    }];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Thumbnail
//-------------------------------------------------------------------------------------------

- (void)getLocalThumbnailImage:(void (^)(Image *thumbnail))completion
{
    if (self.kind == CCFileKind._photo) {
        if (self.originalImage) {
            SafetyCall(completion, self.originalImage);
        } else if (self.thumbnail) {
            SafetyCall(completion, self.thumbnail);
        } else if (self.libraryAsset) {
            [self render:self.libraryAsset fast:YES size:CGSizeMake(210, 210) completion:^(Image *image, NSError *error) {
                self.thumbnail = image;
                SafetyCall(completion, image);
            }];
        }
    } else {
        SafetyCall(completion, self.thumbnail);
    }
}

//-------------------------------------------------------------------------------------------
#pragma mark - Private
//-------------------------------------------------------------------------------------------

- (void)setUploadName:(NSString *)uploadName
{
    [self willChangeValueForKey:@"states"];
    _uploadName = uploadName;
    [self didChangeValueForKey:@"states"];
}

- (void)setOriginalImage:(Image *)originalImage
{
    [self willChangeValueForKey:@"states"];
    _originalImage = originalImage;
    [self didChangeValueForKey:@"states"];
}

- (void)setLibraryAsset:(PHAsset *)libraryAsset
{
    [self willChangeValueForKey:@"states"];
    _libraryAsset = libraryAsset;
    [self didChangeValueForKey:@"states"];
}

- (void)setFilePath:(NSString *)filePath
{
    [self willChangeValueForKey:@"states"];
    _filePath = filePath;
    [self didChangeValueForKey:@"states"];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Assets Library rendering
//-------------------------------------------------------------------------------------------

- (void)render:(PHAsset *)asset fast:(BOOL)fast size:(CGSize)size completion:(void (^)(Image *image, NSError *error))completion
{
    PHImageManager *imageManager = PHImageManager.defaultManager;

    PHImageRequestOptions *requestOptions = PHImageRequestOptions.new;
    requestOptions.resizeMode = fast ? PHImageRequestOptionsResizeModeFast : PHImageRequestOptionsResizeModeExact;
    requestOptions.deliveryMode = fast ? PHImageRequestOptionsDeliveryModeFastFormat : PHImageRequestOptionsDeliveryModeHighQualityFormat;
    requestOptions.synchronous = fast;

    CGFloat smallSide = fminf(size.width, size.height);

    [imageManager requestImageForAsset:asset
                            targetSize:CGSizeMake(smallSide, smallSide)
                           contentMode:PHImageContentModeAspectFill  //PHImageContentModeDefault
                               options:requestOptions
                         resultHandler:^void(Image *image, NSDictionary *info) {
                             NSError *error = info[PHImageErrorKey];
                             if (error) {
                                 NSLog(@"Can't get image for asset '%@': %@", self, error);
                             }
                             SafetyCall(completion, image, error);
                         }];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Image Utils
//-------------------------------------------------------------------------------------------

- (NSData *)dataFromImage:(Image *)image
{
#if TARGET_OS_IPHONE
    return UIImageJPEGRepresentation(image, 0.8);
#else
    NSData *imageData = [image TIFFRepresentation];
    NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
    NSNumber *compressionFactor = [NSNumber numberWithFloat:0.8];
    NSDictionary *imageProps = [NSDictionary dictionaryWithObject:compressionFactor
                                                           forKey:NSImageCompressionFactor];
    return [imageRep representationUsingType:NSJPEGFileType properties:imageProps];
#endif
}

@end
