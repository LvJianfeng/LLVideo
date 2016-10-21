//
//  VideoPlayViewController.m
//  LLVideoDemo
//
//  Created by LvJianfeng on 2016/10/21.
//  Copyright © 2016年 LvJianfeng. All rights reserved.
//
//屏幕宽
#define ll_SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
//屏幕高
#define ll_SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)

#import "VideoPlayViewController.h"

@interface VideoPlayViewController () <AVPlayerViewControllerDelegate>
{
    AVPlayer *tempPlayer;
    AVPlayerItem *tempPlayerItem;
}
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIView *contrainerView;
@property (weak, nonatomic) UIImageView *firstPageImageView;
//播放地址
@property (strong, nonatomic) NSURL *videoURL;
@end

@implementation VideoPlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.videoURL = [[NSBundle mainBundle] URLForResource:@"JiveBike" withExtension:@"mov"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayDidEnd)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:nil];
    
    AVAsset *movieAsset = [AVURLAsset URLAssetWithURL:self.videoURL options:nil];
    tempPlayerItem = [AVPlayerItem playerItemWithAsset:movieAsset];
    //添加监听
    [tempPlayerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    [tempPlayerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    
    
    AVPlayer *player = [AVPlayer playerWithPlayerItem:tempPlayerItem];
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    playerLayer.frame = CGRectMake(0, 0, ll_SCREEN_WIDTH, 240);
    playerLayer.videoGravity =AVLayerVideoGravityResizeAspect;
    [self.contrainerView.layer addSublayer:playerLayer];
    tempPlayer = player;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/*
 *  播放或暂停
 */
- (IBAction)play:(id)sender {
    if ([self.playButton.titleLabel.text isEqualToString:@"重新播放"]) {
        
    }else{
        if (tempPlayer.rate == 1) {
            [tempPlayer pause];
            [self.playButton setTitle:@"播放" forState:UIControlStateNormal];
        }else{
            [tempPlayer play];
            [self.playButton setTitle:@"暂停" forState:UIControlStateNormal];
        }
    }
}

/*
 *  播放结束
 */
- (void)moviePlayDidEnd{
    [self.playButton setTitle:@"重新播放" forState:UIControlStateNormal];
}

/*
 *  present AVPlayerViewController 进行视频播放
 */
- (IBAction)systemAVPlayerAction:(id)sender {
    AVPlayerViewController * play = [[AVPlayerViewController alloc]init];
    play.player = [[AVPlayer alloc]initWithURL:self.videoURL];
    [self presentViewController:play animated:YES completion:nil];
}

/*
 *  监听回调
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    
    if ([keyPath isEqualToString:@"loadedTimeRanges"]){
        NSTimeInterval loadedTime = [self availableDurationWithplayerItem:playerItem];
        NSTimeInterval totalTime = CMTimeGetSeconds(playerItem.duration);
        
        NSLog(@"loadedTime:%f--totalTime:%f",loadedTime,totalTime);
    }else if ([keyPath isEqualToString:@"status"]){
        if (playerItem.status == AVPlayerItemStatusReadyToPlay){
            NSLog(@"playerItem is ready");
            [tempPlayer play];
            [self.playButton setTitle:@"暂停" forState:UIControlStateNormal];
        } else{
            NSLog(@"load break");
        }
    }
}

- (NSTimeInterval)availableDurationWithplayerItem:(AVPlayerItem *)playerItem
{
    NSArray *loadedTimeRanges = [playerItem loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    NSTimeInterval startSeconds = CMTimeGetSeconds(timeRange.start);
    NSTimeInterval durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}

- (void)dealloc
{
    NSLog(@"dead");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [tempPlayerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [tempPlayerItem removeObserver:self forKeyPath:@"status"];
}

@end
