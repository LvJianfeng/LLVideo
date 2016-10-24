//
//  RecordTwoViewController.m
//  LLVideoDemo
//
//  Created by LvJianfeng on 2016/10/21.
//  Copyright © 2016年 LvJianfeng. All rights reserved.
//

#import "RecordTwoViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

//屏幕宽
#define ll_SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
//屏幕高
#define ll_SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)


@interface RecordTwoViewController () <AVCaptureFileOutputRecordingDelegate>
@property (nonatomic) dispatch_queue_t sessionQueue;
/**
 *  AVCaptureSession对象来执行输入设备和输出设备之间的数据传递
 */
@property (nonatomic, strong) AVCaptureSession* session;
/**
 *  视频输入设备
 */
@property (nonatomic, strong) AVCaptureDeviceInput* videoInput;
/**
 *  声音输入
 */
@property (nonatomic, strong) AVCaptureDeviceInput* audioInput;
/**
 *  视频输出流
 */
@property(nonatomic,strong)AVCaptureMovieFileOutput *movieFileOutput;
/**
 *  预览图层
 */
@property (nonatomic, strong) AVCaptureVideoPreviewLayer* previewLayer;
/**
 *  记录录制时间
 */
@property (nonatomic, strong) NSTimer* timer;
@property (weak, nonatomic) IBOutlet UIView *capView;
@end

@implementation RecordTwoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initAVCaptureSession];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)initAVCaptureSession{
    self.session = [[AVCaptureSession alloc] init];
//    self.session.sessionPreset = AVAssetExportPreset640x480;
    
    NSError *error;
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    [device lockForConfiguration:nil];
    
    [device unlockForConfiguration];
    
    self.videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:device error:&error];
    self.audioInput = [[AVCaptureDeviceInput alloc] initWithDevice:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio] error:nil];
    
    if (error) {
        NSLog(@"viewDidLoad->error->%@",error);
    }
    
    self.movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
    
    if ([self.session canAddInput:self.videoInput]) {
        [self.session addInput:self.videoInput];
    }
    
    if ([self.session canAddInput:self.audioInput]) {
        [self.session addInput:self.audioInput];
    }
    
    if ([self.session canAddOutput:self.movieFileOutput]) {
        [self.session addOutput:self.movieFileOutput];
    }
    
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
    
    self.previewLayer.frame = CGRectMake(0, 0, ll_SCREEN_WIDTH, 350);
    self.capView.layer.masksToBounds = YES;
    [self.capView.layer insertSublayer:self.previewLayer atIndex:0];
    
    [self.session startRunning];
}



/*
 * 录制
 */
- (IBAction)record:(id)sender {
    AVCaptureConnection *capConnection = [self.movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
    AVCaptureVideoOrientation capVideoOri = AVCaptureVideoOrientationPortrait;
    [capConnection setVideoOrientation:capVideoOri];
    [capConnection setVideoScaleAndCropFactor:1.0];
    
    
}
@end
