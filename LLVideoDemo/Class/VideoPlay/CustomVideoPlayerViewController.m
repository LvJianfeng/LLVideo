//
//  CustomVideoPlayerViewController.m
//  LLVideoDemo
//
//  Created by LvJianfeng on 2016/10/24.
//  Copyright © 2016年 LvJianfeng. All rights reserved.
//

#import "CustomVideoPlayerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

//屏幕宽
#define ll_SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.height)
//屏幕高
#define ll_SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.width)

@interface CustomVideoPlayerViewController ()
@property(nonatomic,strong)AVPlayer *player; // 播放属性
@property(nonatomic,strong)AVPlayerItem *playerItem; // 播放属性
@property(nonatomic,assign)CGFloat width; // 坐标
@property(nonatomic,assign)CGFloat height; // 坐标
@property(nonatomic,strong)UISlider *slider; // 进度条
@property(nonatomic,strong)UILabel *currentTimeLabel; // 当前播放时间
@property(nonatomic,strong)UILabel *systemTimeLabel; // 系统时间
@property(nonatomic,strong)UIView *backView; // 上面一层Viewd
@property(nonatomic,assign)CGPoint startPoint;
@property(nonatomic,assign)CGFloat systemVolume;
@property(nonatomic,strong)UISlider *volumeViewSlider;
@property(nonatomic,strong)UIActivityIndicatorView *activity; // 系统菊花
@property(nonatomic,strong)UIProgressView *progress; // 缓冲条
@property(nonatomic,strong)UIView *topView;

//播放地址
@property (strong, nonatomic) NSURL *videoURL;
@end

@implementation CustomVideoPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.videoURL = [NSURL URLWithString:@"http://221.229.165.31:80/play/274CF5C996AFCE2C751D315B5D1BF131B8C08208/298088%255Fstandard.mp4"];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    AVAsset *movieAsset = [AVURLAsset URLAssetWithURL:self.videoURL options:nil];
    self.playerItem = [AVPlayerItem playerItemWithAsset:movieAsset];
    
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    playerLayer.frame = CGRectMake(0, 0, ll_SCREEN_WIDTH, ll_SCREEN_HEIGHT);
    playerLayer.videoGravity = AVLayerVideoGravityResize;
    
    [self.view.layer addSublayer:playerLayer];
    
    [self.player play];
    
    //AVPlayer播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
    
    self.backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ll_SCREEN_WIDTH, ll_SCREEN_HEIGHT)];
    [self.view addSubview:self.backView];
    self.backView.backgroundColor = [UIColor clearColor];
    
    self.topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ll_SCREEN_WIDTH, ll_SCREEN_HEIGHT * 0.15)];
    self.topView.backgroundColor = [UIColor blackColor];
    self.topView.alpha = 0.5;
    [self.backView addSubview:self.topView];
    
    [self.playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    
    //UIProgressView
    [self createProgress];
    [self createSlider];
    [self createCurrentTimeLabel];
    [self createButton];
    [self backButton];
    [self createTitle];
    [self createGesture];
    
    [self customVideoSlider];
    
    self.activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.activity.center = self.backView.center;
    [self.view addSubview:self.activity];
    [self.activity startAnimating];
    
    //延迟
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.5 animations:^{
            self.backView.alpha = 0;
        }];
    });
    
    [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(stack) userInfo:nil repeats:YES];
}

- (void)moviePlayDidEnd:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
 * 计时器事件
 */
- (void)stack{
    if (self.playerItem.duration.timescale != 0) {
        self.slider.maximumValue = 1;
        self.slider.value = CMTimeGetSeconds([self.playerItem currentTime]) / (self.playerItem.duration.value / self.playerItem.duration.timescale);
        
        //当前时长进度progress
        NSInteger proMin = (NSInteger)CMTimeGetSeconds([self.player currentTime]) / 60; //当前秒
        NSInteger proSec = (NSInteger)CMTimeGetSeconds([self.player currentTime]) % 60; //当前分钟
        
        NSInteger durMin = (NSInteger)self.playerItem.duration.value / self.playerItem.duration.timescale / 60; //总秒
        NSInteger durSec = (NSInteger)self.playerItem.duration.value / self.playerItem.duration.timescale % 60; //总分钟
        self.currentTimeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld / %02ld:%02ld", proMin, proSec, durMin, durSec];
    }
    if (self.player.status == AVPlayerStatusReadyToPlay) {
        [self.activity stopAnimating];
    }else{
        [self.activity startAnimating];
    }
}

/*
 * 横屏
 */
- (BOOL)shouldAutorotate{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscape;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationLandscapeRight;
}

- (BOOL)prefersStatusBarHidden{
    return NO;
}

/*
 * 创建UIProgressView
 */
- (void)createProgress{
    self.progress = [[UIProgressView alloc] initWithFrame:CGRectMake(202, ll_SCREEN_HEIGHT - 30, _width * 0.69, 30)];
    self.progress.backgroundColor = [UIColor redColor];
    [self.backView addSubview:self.progress];
}

/*
 * 创建UISlider
 */
- (void)createSlider{
    self.slider = [[UISlider alloc] initWithFrame:CGRectMake(200, ll_SCREEN_HEIGHT - 45, _width * 0.7, 30)];
    [self.backView addSubview:self.slider];
    [self.slider setThumbImage:[UIImage imageNamed:@"iconfont-yuan"] forState:UIControlStateNormal];
    [self.slider addTarget:self action:@selector(progressSlider:) forControlEvents:UIControlEventValueChanged];
    self.slider.minimumTrackTintColor = [UIColor colorWithRed:30 / 255.0 green:80 / 255.0 blue:100 / 255.0 alpha:1];
}

- (void)progressSlider:(UISlider *)slider{
    //拖动改变视频播放进度
    if (self.player.status == AVPlayerStatusReadyToPlay) {
        //计算拖动的当前秒数
        CGFloat total = (CGFloat)self.playerItem.duration.value / self.playerItem.duration.timescale;
        NSInteger dragedSeconds = floorf(total * slider.value);
        //转换成cmtime 才能控制player的播放进度
        CMTime dragedCMTime = CMTimeMake(dragedSeconds, 1);
        [self.player pause];
        
        [self.player seekToTime:dragedCMTime completionHandler:^(BOOL finished) {
            [_player play];
        }];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        //计算缓冲进度
        NSTimeInterval timeInterval = [self availableDuration];
        CMTime duration = self.playerItem.duration;
        CGFloat totalDuration = CMTimeGetSeconds(duration);
        [self.progress setProgress:timeInterval / totalDuration animated:YES];
    }
}

- (NSTimeInterval)availableDuration{
    NSArray *loadedTimeRanges = [[self.player currentItem] loadedTimeRanges];
    // 获取缓冲区域
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    // 计算缓冲总进度
    NSTimeInterval result = startSeconds + durationSeconds;
    return result;
}

/*
 * 创建播放时间
 */
- (void)createCurrentTimeLabel{
    self.currentTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, ll_SCREEN_HEIGHT - 45, 100, 30)];
    [self.backView addSubview:self.currentTimeLabel];
    
    self.currentTimeLabel.textColor = [UIColor whiteColor];
    self.currentTimeLabel.font = [UIFont systemFontOfSize:12];
    self.currentTimeLabel.text = @"00:00/00:00";
}

/*
 * 播放和下一首按钮
 */
- (void)createButton{
    UIButton *startButton = [UIButton buttonWithType:UIButtonTypeCustom];
    startButton.frame = CGRectMake(15, ll_SCREEN_HEIGHT - 45, 30, 30);
    [self.backView addSubview:startButton];
    if (self.player.rate == 1.0) {
        [startButton setBackgroundImage:[UIImage imageNamed:@"pauseBtn"] forState:UIControlStateNormal];
    }else{
        [startButton setBackgroundImage:[UIImage imageNamed:@"playBtn"] forState:UIControlStateNormal];
    }
    [startButton addTarget:self action:@selector(startAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    nextButton.frame = CGRectMake(55, ll_SCREEN_HEIGHT - 45, 30, 30);
    [self.backView addSubview:nextButton];
    [nextButton setBackgroundImage:[UIImage imageNamed:@"nextPlayer"] forState:UIControlStateNormal];
}

/*
 * 播放暂停按钮方法
 */
- (void)startAction:(UIButton *)button{
    if (button.selected) {
        [self.player play];
        [button setBackgroundImage:[UIImage imageNamed:@"pauseBtn"] forState:UIControlStateNormal];
    }else{
        [self.player pause];
        [button setBackgroundImage:[UIImage imageNamed:@"playBtn"] forState:UIControlStateNormal];
    }
    button.selected = !button.selected;
}

/*
 * 返回按钮方法
 */
- (void)backButton{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(15, 20, 30, 30);
    [button setBackgroundImage:[UIImage imageNamed:@"iconfont-back"] forState:UIControlStateNormal];
    [self.topView addSubview:button];
    [button addTarget:self action:@selector(backButtonAction) forControlEvents:UIControlEventTouchUpInside];
}

- (void)backButtonAction{
    [self.player pause];
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
 * 创建标题
 */
- (void)createTitle{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(80, 20, 250, 30)];
    [self.backView addSubview:label];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
}

/*
 * 创建手势
 */
- (void)createGesture{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [self.view addGestureRecognizer:tapGesture];
    
    //获取系统音量
    MPVolumeView *volumeView = [[MPVolumeView alloc] init];
    self.volumeViewSlider = nil;
    for (UIView *view in [volumeView subviews]) {
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]) {
            self.volumeViewSlider = (UISlider *)view;
            break;
        }
    }
    self.systemVolume = self.volumeViewSlider.value;
}

/*
 * 轻拍方法
 */
- (void)tapAction:(UITapGestureRecognizer *)tap{
    if (self.backView.alpha == 1) {
        [UIView animateWithDuration:0.5 animations:^{
            self.backView.alpha = 0;
        }];
    }else if(self.backView.alpha == 0){
        [UIView animateWithDuration:0.5 animations:^{
            self.backView.alpha = 1;
        }];
    }
    
    if (self.backView.alpha == 1) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.5 animations:^{
                self.backView.alpha = 0;
            }];
        });
    }
}

/*
 * 滑动调整音量大小
 */
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (event.allTouches.count == 1) {
        CGPoint point = [[touches anyObject] locationInView:self.view];
        self.startPoint = point;
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (event.allTouches.count == 1) {
        CGPoint point = [[touches anyObject] locationInView:self.view];
        float dy = point.y - self.startPoint.y;
        int index = (int)dy;
        if (index > 0) {
            if (index % 5 == 0) {
                if (self.systemVolume > 0.1) {
                    self.systemVolume = self.systemVolume - 0.05;
                    [self.volumeViewSlider setValue:self.systemVolume animated:YES];
                    [self.volumeViewSlider sendActionsForControlEvents:UIControlEventTouchUpInside];
                }
            }
        }else{
            if (index % 5 == 0) {
                if (self.systemVolume >= 0 && self.systemVolume < 1) {
                    self.systemVolume = self.systemVolume+0.05;
                    [self.volumeViewSlider setValue:self.systemVolume animated:YES];
                    [self.volumeViewSlider sendActionsForControlEvents:UIControlEventTouchUpInside];
                }
            }
        }
    }
}

- (void)customVideoSlider{
    UIGraphicsBeginImageContextWithOptions((CGSize){1,1}, NO, 0);
    UIImage *transparentImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self.slider setMaximumTrackImage:transparentImage forState:UIControlStateNormal];
}

- (void)dealloc
{
//    [self.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
