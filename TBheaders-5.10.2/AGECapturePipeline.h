//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2015 by Steve Nygard.
//

#import <Foundation/NSObject.h>

#import "AGEMovieRecorderDelegate-Protocol.h"
#import "AVCaptureVideoDataOutputSampleBufferDelegate-Protocol.h"

@class AGEMovieRecorder, AVCaptureConnection, AVCaptureDevice, AVCaptureSession, AVCaptureVideoDataOutput, NSMutableDictionary, NSString, NSURL;
@protocol AGECapturePipelineDelegate, OS_dispatch_queue;

@interface AGECapturePipeline : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate, AGEMovieRecorderDelegate>
{
    NSObject<OS_dispatch_queue> *_sessionQueue;	// 8 = 0x8
    NSObject<OS_dispatch_queue> *_videoDataOutputQueue;	// 16 = 0x10
    unsigned long long _pipelineRunningTask;	// 24 = 0x18
    NSObject<OS_dispatch_queue> *_delegateCallbackQueue;	// 32 = 0x20
    _Bool _startCaptureSessionOnEnteringForeground;	// 40 = 0x28
    _Bool _running;	// 41 = 0x29
    AVCaptureSession *_captureSession;	// 48 = 0x30
    AVCaptureDevice *_videoDevice;	// 56 = 0x38
    NSURL *_videoUrl;	// 64 = 0x40
    long long _videoOrientation;	// 72 = 0x48
    long long _recordingOrientation;	// 80 = 0x50
    long long _recordingStatus;	// 88 = 0x58
    AGEMovieRecorder *_recorder;	// 96 = 0x60
    AVCaptureVideoDataOutput *_videoOut;	// 104 = 0x68
    AVCaptureConnection *_videoConnection;	// 112 = 0x70
    NSMutableDictionary *_videoCompressionSettings;	// 120 = 0x78
    struct opaqueCMFormatDescription *_outputVideoFormatDescription;	// 128 = 0x80
    struct opaqueCMFormatDescription *_outputAudioFormatDescription;	// 136 = 0x88
    struct __CVBuffer *_currentPreviewPixelBuffer;	// 144 = 0x90
    id <AGECapturePipelineDelegate> _delegate;	// 152 = 0x98
}

@property(nonatomic) __weak id <AGECapturePipelineDelegate> delegate; // @synthesize delegate=_delegate;
@property(retain, nonatomic) struct __CVBuffer *currentPreviewPixelBuffer; // @synthesize currentPreviewPixelBuffer=_currentPreviewPixelBuffer;
@property(retain, nonatomic) struct opaqueCMFormatDescription *outputAudioFormatDescription; // @synthesize outputAudioFormatDescription=_outputAudioFormatDescription;
@property(retain, nonatomic) struct opaqueCMFormatDescription *outputVideoFormatDescription; // @synthesize outputVideoFormatDescription=_outputVideoFormatDescription;
@property(retain, nonatomic) NSMutableDictionary *videoCompressionSettings; // @synthesize videoCompressionSettings=_videoCompressionSettings;
@property(retain, nonatomic) AVCaptureConnection *videoConnection; // @synthesize videoConnection=_videoConnection;
@property(retain, nonatomic) AVCaptureVideoDataOutput *videoOut; // @synthesize videoOut=_videoOut;
@property(retain, nonatomic) AGEMovieRecorder *recorder; // @synthesize recorder=_recorder;
@property(nonatomic) long long recordingStatus; // @synthesize recordingStatus=_recordingStatus;
@property(nonatomic) _Bool running; // @synthesize running=_running;
@property(nonatomic) _Bool startCaptureSessionOnEnteringForeground; // @synthesize startCaptureSessionOnEnteringForeground=_startCaptureSessionOnEnteringForeground;
@property(nonatomic) long long recordingOrientation; // @synthesize recordingOrientation=_recordingOrientation;
@property(nonatomic) long long videoOrientation; // @synthesize videoOrientation=_videoOrientation;
@property(retain, nonatomic) NSURL *videoUrl; // @synthesize videoUrl=_videoUrl;
@property(retain, nonatomic) AVCaptureDevice *videoDevice; // @synthesize videoDevice=_videoDevice;
@property(retain, nonatomic) AVCaptureSession *captureSession; // @synthesize captureSession=_captureSession;
- (void).cxx_destruct;
- (void)setupVideoPipelineWithInputFormatDescription:(struct opaqueCMFormatDescription *)arg1;
- (void)videoPipelineDidRunOutOfBuffers;
- (void)videoPipelineDidFinishRunning;
- (void)videoPipelineWillStartRunning;
- (void)renderVideoSampleBuffer:(struct opaqueCMSampleBuffer *)arg1;
- (void)captureOutput:(id)arg1 didOutputSampleBuffer:(struct opaqueCMSampleBuffer *)arg2 fromConnection:(id)arg3;
- (void)outputPreviewPixelBuffer:(struct __CVBuffer *)arg1;
- (void)savedToPhotosAlbum;
- (void)movieRecorderDidFinishRecording:(id)arg1;
- (void)movieRecorder:(id)arg1 didFailWithError:(id)arg2;
- (void)movieRecorderDidFinishPreparing:(id)arg1;
- (struct CGAffineTransform)transformFromVideoBufferOrientationToOrientation:(long long)arg1 withAutoMirroring:(_Bool)arg2;
- (void)stopRecording;
- (void)startRecordingWithFileUrl:(id)arg1;
- (void)teardownVideoPipeline;
- (void)teardownCaptureSession;
- (void)handleNonRecoverableCaptureSessionRuntimeError:(id)arg1;
- (void)handleRecoverableCaptureSessionRuntimeError:(id)arg1;
- (void)transitionToRecordingStatus:(long long)arg1 error:(id)arg2;
- (void)captureSessionDidStopRunning;
- (void)captureSessionNotification:(id)arg1;
- (void)applicationWillEnterForeground;
- (void)setupCaptureConnection;
- (void)setupCapturePreset;
- (void)setupCaptureSession;
- (void)stopRunning;
- (void)startRunning;
- (void)setDelegate:(id)arg1 callbackQueue:(id)arg2;
- (id)init;

// Remaining properties
@property(readonly, copy) NSString *debugDescription;
@property(readonly, copy) NSString *description;
@property(readonly) unsigned long long hash;
@property(readonly) Class superclass;

@end

