//
//  GIFView.m
//  GIFView
//
//  Created by frankgwang on 13-9-8.
//  Copyright (c) 2013年 Tencent SNS Terminal Develope Center. All rights reserved.
//

#import "GIFView.h"
#import <ImageIO/ImageIO.h>

static CGImageRef createImageAfterDecode(CGImageRef imageRef)
{
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    size_t bitsPerComponent = CGImageGetBitsPerComponent(imageRef);
    size_t bytesPerRow = 0; // CGImageGetBytesPerRow() calculates incorrectly in iOS 5.0, so defer to CGBitmapContextCreate()
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    
    if (CGColorSpaceGetNumberOfComponents(colorSpace) == 3)
    {
        int alpha = (bitmapInfo & kCGBitmapAlphaInfoMask);
        if (alpha == kCGImageAlphaNone) {
            bitmapInfo &= ~kCGBitmapAlphaInfoMask;
            bitmapInfo |= kCGImageAlphaNoneSkipFirst;
        } else if (!(alpha == kCGImageAlphaNoneSkipFirst || alpha == kCGImageAlphaNoneSkipLast))
        {
            bitmapInfo &= ~kCGBitmapAlphaInfoMask;
            bitmapInfo |= kCGImageAlphaPremultipliedFirst;
        }
    }
    
    CGContextRef context = CGBitmapContextCreate(NULL, width, height, bitsPerComponent, bytesPerRow, colorSpace, bitmapInfo);
    
    CGColorSpaceRelease(colorSpace);
    
    CGRect rect = CGRectMake(0.0f, 0.0f, width, height);
    CGContextDrawImage(context, rect, imageRef);
    CGImageRef decodedImage = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    return decodedImage;
}

@interface GIFView()
@property (nonatomic) CGImageSourceRef imageSource;
@property (nonatomic, strong) NSDictionary *imageSourceOptions;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic) int frameCount;
@property (nonatomic) uint64_t frameIndex;
@property (nonatomic) BOOL isPaused;
@property (nonatomic) NSArray *frameIntervals;
@property (nonatomic) CAKeyframeAnimation *animation;
@end

@implementation GIFView

#pragma mark - iva

- (void)setRepeatCount:(float)repeatCount
{
	_repeatCount=MAX(repeatCount, 1);
}

- (void)setGIFData:(NSData *)GIFData
{
	_GIFData=GIFData;
	
	if (_imageSource)
		CFRelease(_imageSource);
	
	_imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)GIFData, (__bridge CFDictionaryRef)_imageSourceOptions);
	_frameCount=(int)CGImageSourceGetCount(_imageSource);
	
    NSMutableArray *frameIntervals = [NSMutableArray array];
    NSMutableArray *images=[NSMutableArray array];
    
    _totalDuration=0;
    CGImageRef imageRef;
    float frameInterval;
    NSDictionary *property, *tmpDict;
    
    for (int i=0; i<_frameCount; ++i)
    {
        imageRef=CGImageSourceCreateImageAtIndex(_imageSource, i, (__bridge CFDictionaryRef)_imageSourceOptions);
        [images addObject:(__bridge_transfer id)(createImageAfterDecode(imageRef))];
        CGImageRelease(imageRef);
        
        property=(__bridge_transfer NSDictionary *)(CGImageSourceCopyPropertiesAtIndex(_imageSource, i, NULL));
        tmpDict=property[(__bridge_transfer NSString*)kCGImagePropertyGIFDictionary];
        frameInterval=[tmpDict[(__bridge_transfer NSString*)kCGImagePropertyGIFDelayTime] floatValue];
        [frameIntervals addObject:@(frameInterval)];
        
        _totalDuration+=frameInterval;
    }
    
    NSMutableArray *intervalArray=[NSMutableArray array];
    [intervalArray addObject:@0];
    for (int i=1; i<_frameCount; ++i)
    {
        [intervalArray addObject:@([intervalArray[i-1] floatValue]+[frameIntervals[i] floatValue]/_totalDuration)];
    }
    [intervalArray addObject:@1];
    
    _frameIntervals=[NSArray arrayWithArray:intervalArray];
    
    _animation = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
    _animation.values=images;
    _animation.keyTimes=intervalArray;
    _animation.duration = _totalDuration;
    _animation.repeatCount = _repeatCount;
}

#pragma mark - life circle

- (id)init
{
    self=[super init];
	if (self)
	{
        _imageSourceOptions=@{(NSString *)kCGImagePropertyGIFDictionary: @{(NSString*)kCGImagePropertyGIFLoopCount: @0}};
		_repeatCount=HUGE_VALF;
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame
{
	self=[super initWithFrame:frame];
	if (self)
	{
        _imageSourceOptions=@{(NSString *)kCGImagePropertyGIFDictionary: @{(NSString*)kCGImagePropertyGIFLoopCount: @0}};
		_repeatCount=HUGE_VALF;
	}
	return self;
}

- (void)dealloc
{
	if (_imageSource)
	{
		CFRelease(_imageSource);
		_imageSource=NULL;
	}
}

- (void)sizeToFit
{
	if (!_GIFData)
		return;
	
	CGImageRef image=CGImageSourceCreateImageAtIndex(_imageSource, 0, (__bridge CFDictionaryRef)_imageSourceOptions);
	
	if (image==NULL)
		return;
	
	self.frame=CGRectMake(self.frame.origin.x, self.frame.origin.y, CGImageGetWidth(image), CGImageGetHeight(image));
	CGImageRelease(image);
}

#pragma mark - buz

- (void)startAnimation
{
    [self.layer addAnimation:_animation forKey:@"contents"];
}

- (void)stopAnimation
{
    self.layer.contents=(__bridge_transfer id)CGImageSourceCreateImageAtIndex(_imageSource, 0, (__bridge CFDictionaryRef)_imageSourceOptions);;
    [self.layer removeAnimationForKey:@"contents"];
}

@end
