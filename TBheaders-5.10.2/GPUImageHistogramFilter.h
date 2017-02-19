//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2015 by Steve Nygard.
//

#import "GPUImageFilter.h"

@class GLProgram;

@interface GPUImageHistogramFilter : GPUImageFilter
{
    int histogramType;	// 216 = 0xd8
    char *vertexSamplingCoordinates;	// 224 = 0xe0
    GLProgram *secondFilterProgram;	// 232 = 0xe8
    GLProgram *thirdFilterProgram;	// 240 = 0xf0
    int secondFilterPositionAttribute;	// 248 = 0xf8
    int thirdFilterPositionAttribute;	// 252 = 0xfc
    unsigned long long _downsamplingFactor;	// 256 = 0x100
}

@property(nonatomic) unsigned long long downsamplingFactor; // @synthesize downsamplingFactor=_downsamplingFactor;
- (void).cxx_destruct;
- (void)renderToTextureWithVertices:(const float *)arg1 textureCoordinates:(const float *)arg2 sourceTexture:(unsigned int)arg3;
- (void)setInputRotation:(int)arg1 atIndex:(long long)arg2;
- (void)setInputSize:(struct CGSize)arg1 atIndex:(long long)arg2;
- (struct CGSize)outputFrameSize;
- (void)newFrameReadyAtTime:(CDStruct_1b6d18a9)arg1 atIndex:(long long)arg2;
- (struct CGSize)sizeOfFBO;
- (void)generatePointCoordinates;
- (void)dealloc;
- (void)initializeSecondaryAttributes;
- (id)initWithHistogramType:(int)arg1;

@end
