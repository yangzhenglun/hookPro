//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "NSObject.h"

#import "IJKMediaPlayback.h"

@class IJKFFConferencePlayerMessagePool, IJKFFMrl, IJKSDLGLView, NSDate, NSDictionary, NSMutableArray, NSString, UIView;

@interface IJKFFConferencePlayerController : NSObject <IJKMediaPlayback>
{
    IJKFFMrl *_ffMrl;
    id <IJKMediaSegmentResolver> _segmentResolver;
    struct IjkMediaConferencePlayer *_mediaPlayer;
    IJKSDLGLView *_glView;
    IJKFFConferencePlayerMessagePool *_msgPool;
    long long _videoWidth;
    long long _videoHeight;
    long long _sampleAspectRatioNumerator;
    long long _sampleAspectRatioDenominator;
    NSDate *_audioInterruptBeginTS;
    NSDate *_audioInterruptEndTS;
    _Bool _seeking;
    long long _bufferingTime;
    long long _bufferingPosition;
    _Bool _keepScreenOnWhilePlaying;
    _Bool _pauseInBackground;
    _Bool _isVideoToolboxOpen;
    NSMutableArray *_registeredNotifications;
    _Bool _isPreparedToPlay;
    _Bool _shouldAutoplay;
    _Bool _allowsMediaAirPlay;
    _Bool _airPlayMediaActive;
    _Bool _isDanmakuMediaAirPlay;
    _Bool _isShutdown;
    UIView *_view;
    double currentPlaybackTime;
    double duration;
    double playableDuration;
    long long _bufferingProgress;
    long long _numberOfBytesTransferred;
    long long _playbackState;
    unsigned long long _loadState;
    long long _controlStyle;
    long long _scalingMode;
    NSDictionary *_mediaMeta;
    NSDictionary *_videoMeta;
    NSDictionary *_audioMeta;
    double _fpsInMeta;
    id <IJKFFConferencePlayerControllerDelegate> _delegate;
}

+ (void)setLogLevel:(int)arg1;
+ (void)setLogReport:(_Bool)arg1;
@property(nonatomic) _Bool isShutdown; // @synthesize isShutdown=_isShutdown;
@property(nonatomic) __weak id <IJKFFConferencePlayerControllerDelegate> delegate; // @synthesize delegate=_delegate;
@property(readonly, nonatomic) double fpsInMeta; // @synthesize fpsInMeta=_fpsInMeta;
@property(readonly, nonatomic) NSDictionary *audioMeta; // @synthesize audioMeta=_audioMeta;
@property(readonly, nonatomic) NSDictionary *videoMeta; // @synthesize videoMeta=_videoMeta;
@property(readonly, nonatomic) NSDictionary *mediaMeta; // @synthesize mediaMeta=_mediaMeta;
@property(nonatomic) long long scalingMode; // @synthesize scalingMode=_scalingMode;
@property(nonatomic) long long controlStyle; // @synthesize controlStyle=_controlStyle;
@property(readonly, nonatomic) unsigned long long loadState; // @synthesize loadState=_loadState;
@property(readonly, nonatomic) _Bool isPreparedToPlay; // @synthesize isPreparedToPlay=_isPreparedToPlay;
@property(readonly, nonatomic) long long numberOfBytesTransferred; // @synthesize numberOfBytesTransferred=_numberOfBytesTransferred;
@property(readonly, nonatomic) long long bufferingProgress; // @synthesize bufferingProgress=_bufferingProgress;
@property(readonly, nonatomic) UIView *view; // @synthesize view=_view;
- (void).cxx_destruct;
- (void)applicationWillTerminate;
- (void)applicationDidEnterBackground;
- (void)applicationWillResignActive;
- (void)applicationDidBecomeActive;
- (void)applicationWillEnterForeground;
- (void)unregisterApplicationObserverAll;
- (void)unregisterApplicationObservers;
- (void)registerApplicationObservers;
- (void)setMaxBufferSize:(int)arg1;
- (void)setPlayerOptionIntValue:(long long)arg1 forKey:(id)arg2;
- (void)setSwsOptionIntValue:(long long)arg1 forKey:(id)arg2;
- (void)setCodecOptionIntValue:(long long)arg1 forKey:(id)arg2;
- (void)setFormatOptionIntValue:(long long)arg1 forKey:(id)arg2;
- (void)setPlayerOptionValue:(id)arg1 forKey:(id)arg2;
- (void)setSwsOptionValue:(id)arg1 forKey:(id)arg2;
- (void)setCodecOptionValue:(id)arg1 forKey:(id)arg2;
- (void)setFormatOptionValue:(id)arg1 forKey:(id)arg2;
@property(nonatomic) _Bool isDanmakuMediaAirPlay; // @synthesize isDanmakuMediaAirPlay=_isDanmakuMediaAirPlay;
@property(readonly, nonatomic) _Bool airPlayMediaActive; // @synthesize airPlayMediaActive=_airPlayMediaActive;
@property(nonatomic) _Bool allowsMediaAirPlay; // @synthesize allowsMediaAirPlay=_allowsMediaAirPlay;
- (id)obtainMessage;
- (void)postEvent:(id)arg1;
@property(readonly, nonatomic) double fpsAtOutput;
- (id)thumbnailImageAtCurrentTime;
- (id)thumbnailImageAtTime:(double)arg1 timeOption:(long long)arg2;
@property(readonly, nonatomic) double playableDuration; // @synthesize playableDuration;
@property(readonly, nonatomic) double duration; // @synthesize duration;
@property(nonatomic) double currentPlaybackTime; // @synthesize currentPlaybackTime;
@property(readonly, nonatomic) long long playbackState; // @synthesize playbackState=_playbackState;
- (void)shutdownClose:(id)arg1;
- (void)shutdownWaitStop:(id)arg1;
- (void)shutdown;
- (void)setOptionIntValue:(long long)arg1 forKey:(id)arg2 ofCategory:(int)arg3;
- (void)setOptionValue:(id)arg1 forKey:(id)arg2 ofCategory:(int)arg3;
- (_Bool)isVideoToolboxOpen;
- (void)setPauseInBackground:(_Bool)arg1;
- (_Bool)isPlaying;
- (void)stop;
- (void)pause;
- (void)playFromAudioInterrupt;
- (void)play;
- (void)setVideoExtradata:(void *)arg1 len:(int)arg2 width:(int)arg3 height:(int)arg4;
- (void)putConferenceDataWithType:(int)arg1 data:(char *)arg2 size:(int)arg3 pts:(long long)arg4;
- (void)prepareToPlay;
@property(nonatomic) _Bool shouldAutoplay; // @synthesize shouldAutoplay=_shouldAutoplay;
- (void)dealloc;
- (float)playerSpeedRate;
- (void)setPlayerSpeedRate:(float)arg1;
- (unsigned long long)currentPlaybackPts;
- (unsigned int)getStreamCount;
- (unsigned long long)getFirstAudioRenderTime;
- (unsigned long long)getLastVideoRenderTimeInMs;
- (unsigned long long)getFirstVideoRenderTime;
- (unsigned long long)getFirstAudioDecodeTime;
- (unsigned long long)getFirstVideoDecodeTime;
- (unsigned long long)getFirstAudioReceiveTime;
- (unsigned long long)getFirstVideoReceiveTime;
- (unsigned long long)getStreamMetaTime;
- (unsigned long long)getTcpConnectTime;
- (unsigned long long)getMetaTime;
- (long long)getVideoRenderCount;
- (long long)getAudioRenderSize;
- (long long)getVideoDecodeCount;
- (long long)getAudioDecodeSize;
- (long long)getVideoCacheDuration;
- (long long)getAudioCacheDuration;
- (long long)getVideoReceiveSize;
- (long long)getAudioReceiveSize;
- (long long)getStreamReceiveSize;
- (id)getServerIpAddr;
- (void)setMute:(_Bool)arg1;
- (void)setScreenOn:(_Bool)arg1;
- (id)initWithContentURLString:(id)arg1 withConfigs:(int)arg2 withSegmentResolver:(id)arg3;
- (id)initWithContentURLStringWithDelegate:(id)arg1 aUrlString:(id)arg2 withConfigs:(int)arg3 withSegmentResolver:(id)arg4;
- (id)initWithContentURLString:(id)arg1 withOptions:(id)arg2 withSegmentResolver:(id)arg3;
- (id)initWithContentURL:(id)arg1 withOptions:(id)arg2 withSegmentResolver:(id)arg3;
- (id)initWithContentURL:(id)arg1 withOptions:(id)arg2;

// Remaining properties
@property(readonly, copy) NSString *debugDescription;
@property(readonly, copy) NSString *description;
@property(readonly) unsigned long long hash;
@property(readonly) Class superclass;

@end
