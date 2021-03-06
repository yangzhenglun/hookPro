//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2015 by Steve Nygard.
//

#import "GPUImageFilter.h"

@interface GPUImageBulgeDistortionFilter : GPUImageFilter
{
    int aspectRatioUniform;	// 216 = 0xd8
    int radiusUniform;	// 220 = 0xdc
    int centerUniform;	// 224 = 0xe0
    int scaleUniform;	// 228 = 0xe4
    double _aspectRatio;	// 232 = 0xe8
    double _radius;	// 240 = 0xf0
    double _scale;	// 248 = 0xf8
    struct CGPoint _center;	// 256 = 0x100
}

@property(nonatomic) double scale; // @synthesize scale=_scale;
@property(nonatomic) double radius; // @synthesize radius=_radius;
@property(nonatomic) struct CGPoint center; // @synthesize center=_center;
@property(nonatomic) double aspectRatio; // @synthesize aspectRatio=_aspectRatio;
- (void)setInputRotation:(int)arg1 atIndex:(long long)arg2;
- (void)setInputSize:(struct CGSize)arg1 atIndex:(long long)arg2;
- (void)forceProcessingAtSize:(struct CGSize)arg1;
- (void)adjustAspectRatio;
- (id)init;

@end

