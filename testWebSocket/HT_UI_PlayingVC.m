//
//  HT_UI_PlayingVC.m
//  HaiTing
//
//  Created by uniview on 16/3/10.
//  Copyright © 2016年 Uniview. All rights reserved.
//

#import "HT_UI_PlayingVC.h"
#import "HT_UI_LyricTVC.h"

//#import "HT_UI_Res.h"
#import "ZYLrcLine.h"
#import "HT_UI_AFNDownload.h"
#import "MBProgressHUD.h"
#import "HT_UI_Slider.h"
#import "Masonry.h"
@interface HT_UI_PlayingVC ()

@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIView *middleView;

@property (nonatomic, strong) UIButton *playOrPauseBtn;
@property (nonatomic, strong) HT_UI_Slider *slider;
@property (nonatomic, strong) UIProgressView *progress;

@property (nonatomic, strong) HT_UI_LyricTVC  *lyricTVC;
@property (nonatomic, assign) HT_UI_PlayManager *player;

@end
@implementation HT_UI_PlayingVC

-(UIButton *)playOrPauseBtn{
    if (!_playOrPauseBtn) {
        _playOrPauseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playOrPauseBtn setTitle:@"播放" forState:UIControlStateNormal];
        _playOrPauseBtn.backgroundColor = [UIColor blueColor];
        [_playOrPauseBtn addTarget:self action:@selector(playOrPauseBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_playOrPauseBtn];
        [_playOrPauseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(0);
            make.bottom.mas_equalTo(-25);
            make.width.height.mas_equalTo(44);
    
        }];
        
    }
    return _playOrPauseBtn;
}
-(UIView *)bottomView{
    if (!_bottomView) {
        _bottomView = [UIView new];
        
        UIButton *btnCir = [UIButton buttonWithType:UIButtonTypeCustom];
        btnCir.backgroundColor = [UIColor colorWithRed: ( arc4random() % 256 / 256.0 ) green: ( arc4random() % 256 / 256.0 ) blue: ( arc4random() % 256 / 256.0 ) alpha:1];;
        [btnCir addTarget:self action:@selector(CirCleClick) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:btnCir];
        [btnCir mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.bottom.mas_equalTo(0);
            make.width.mas_equalTo(WIDTH / 5);
            
        }];
        
        UIButton *btnLast = [UIButton buttonWithType:UIButtonTypeCustom];
        btnLast.backgroundColor = [UIColor colorWithRed: ( arc4random() % 256 / 256.0 ) green: ( arc4random() % 256 / 256.0 ) blue: ( arc4random() % 256 / 256.0 ) alpha:1];;
        [btnLast addTarget:self action:@selector(lastBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:btnLast];
        [btnLast mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.mas_equalTo(0);
            make.left.mas_equalTo(btnCir.mas_right).mas_equalTo(0);
              make.width.mas_equalTo(WIDTH / 5);
            
        }];
        
    
        
        UIButton *btnNext = [UIButton buttonWithType:UIButtonTypeCustom];
        btnNext.backgroundColor = [UIColor colorWithRed: ( arc4random() % 256 / 256.0 ) green: ( arc4random() % 256 / 256.0 ) blue: ( arc4random() % 256 / 256.0 ) alpha:1];
        [btnNext addTarget:self action:@selector(nextBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:btnNext];
        [btnNext mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.mas_equalTo(0);
            make.left.mas_equalTo(btnLast.mas_right).mas_equalTo(WIDTH/5);
              make.width.mas_equalTo(WIDTH / 5);
            
        }];
        
        UIButton *btnVolume = [UIButton buttonWithType:UIButtonTypeCustom];
        
        btnVolume.backgroundColor = [UIColor redColor];;
        [_bottomView addSubview:btnVolume];
        [btnVolume mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.right.mas_equalTo(0);
            make.left.mas_equalTo(btnNext.mas_right).mas_equalTo(0);
            make.width.mas_equalTo(WIDTH / 5);
            
        }];
        

        [self.view addSubview:_bottomView];
        [_bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.left.right.mas_equalTo(0);
            make.height.mas_equalTo(50);
        }];
    }
    return _bottomView;
}
-(UIView *)middleView{
    if (!_middleView) {
        __weak typeof (self) weakself = self;
        _middleView = [UIView new];
        _middleView.backgroundColor = [UIColor grayColor];
        [self.view addSubview:_middleView];
        [_middleView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.mas_equalTo(0);
            make.bottom.mas_equalTo(-50);
           
        }];
        
       
        self.progress = [UIProgressView new];
        self.progress.progressTintColor = [UIColor blueColor];
        [_middleView addSubview:self.progress];
        [self.progress mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(-38);
            make.left.mas_equalTo(10);
            make.right.mas_equalTo(-20);
            //make.height.mas_equalTo(4);
        }];
        
        self.slider = [HT_UI_Slider new];
        self.slider.maximumTrackTintColor = [UIColor greenColor];
        self.slider.minimumTrackTintColor = [UIColor redColor];
        self.slider.backgroundColor = [UIColor clearColor];
        [self.slider setThumbImage:[UIImage imageNamed:@"SliderTrack"] forState:UIControlStateNormal];
        [self.slider addTarget:self action:@selector(slideValueChange:) forControlEvents:UIControlEventValueChanged];
        [_middleView addSubview:self.slider];
        [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
             make.centerY.mas_equalTo(weakself.progress);
            make.left.mas_equalTo(10);
            make.right.mas_equalTo(0);
           //make.height.mas_equalTo();
        }];
        
        
        self.lyricTVC = [HT_UI_LyricTVC new];
        [_middleView addSubview:self.lyricTVC.tableView];
        [self addChildViewController:self.lyricTVC];
          __weak typeof (self) myself = self;
        [self.lyricTVC.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(30);
            make.right.mas_equalTo(-30);
            make.bottom.mas_equalTo(myself.slider.mas_top).mas_equalTo(-10);;
            make.height.mas_equalTo(200);
        }];
        
    }
    return _middleView;
}
-(void)setUPNav{
    self.navigationItem.title = @"最近播放";
    UIImage *image = [UIImage imageNamed:@"返回"];
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStyleDone target:self action:@selector(back:)];
    self.navigationItem.leftBarButtonItem = backItem;
    
    self.navigationItem.title = self.songName;
}
-(void)back:(UIBarButtonItem *)item{
    
    //[self.navigationController dismissViewControllerAnimated:YES completion:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUPNav];
    self.view.backgroundColor = [UIColor whiteColor];
    self.tabBarController.tabBar.frame = CGRectZero;
    self.bottomView.hidden = NO;
    self.middleView.hidden =NO;
    self.playOrPauseBtn.hidden = NO;
    
    self.player = [HT_UI_PlayManager defaultManager];
    self.view.backgroundColor = [UIColor whiteColor];
    
    if (self.songUrl != nil && self.songUrl != nil) {//如果歌曲的url不为空 为本地音乐 设置这个
        [self.player playMusic:self.songUrl];
        //self.navigationItem.title = self.songName;
    }else{
     __weak typeof (self)weakselff = self;
        if (self.musicID == 0) {//musicID 为空 就代表不是打算播放音乐
            //MYLog(@"%ld",self.musicID);
            self.lyricTVC.array = self.player.lyricArr;
            self.player.setProgressBlock = ^(double progress){
                [weakselff.progress setProgress:progress animated:YES];
            };
            self.player.setSliderBlock = ^(double slide){
                [weakselff.slider setValue:slide animated:YES];
            };
            self.player.setTableViewBlock = ^(NSArray *array,NSIndexPath *index,NSArray *lyrics){
                //防止刚进来就被调用 然后不能使用了
                // weakselff.lyricTVC.array = weakselff.player.lyricArr;
                //weakselff.lyricTVC.array = lyrics;
                [weakselff.lyricTVC.tableView reloadRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationNone];
                [weakselff.lyricTVC.tableView scrollToRowAtIndexPath:index atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
            };
        
            return;
        }
        
        __weak typeof (self)weakself = self;
        //查询歌曲详细信息
//        [HT_API_HTTP searchSongDetailWithMid:self.musicID questSuccess:^(id responseObject) {
//            NSArray *resArr = [HT_UI_DataManager getRes:responseObject[@"res"]];
//            if (resArr.count == 0) {
//                NSLog(@"没有播放源");
//             
//                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//                hud.contentColor = [UIColor blackColor];
//                // Set the determinate mode to show task progress.
//                hud.mode = MBProgressHUDModeCustomView;
//                hud.label.text = @"没有播放源";
//                hud.square = YES;
//                [hud hideAnimated:YES afterDelay:1.0f];
//                
//                return ;
//            }
//            HT_UI_Res *singleres = resArr[0];
//            //获得fmt 为MP3格式的音乐
//            for (singleres in resArr) {
//                if ([singleres.fmt isEqualToString:@"mp3"]) {
//                    break;
//                }
//            }
//            //默认只播放MP3格式的
//            if (singleres == nil || ![singleres.fmt isEqualToString:@"mp3"]) {
//                NSLog(@"没有播放源");
//                return ;
//            }
            //    NSString *path = [NSString stringWithFormat:@"/Library/Caches/%@.lrc",@(123)];
            //    NSString *savedPath = [NSHomeDirectory() stringByAppendingString:path];
            //    HT_UI_AFNDownload *down = [HT_UI_AFNDownload new];
            
            //将歌词 URL 转成数组
//            NSArray *lirsi = [[ZYLrcLine lrcLinesWithFileName:singleres.lrc] copy];
//            weakself.lyricTVC.array = [lirsi copy];
//            MYLog(@"%@",singleres.url );
//            [weakself.lyricTVC.tableView reloadData];
//            weakself.player.lyricArr = [lirsi copy];
//            //    [down downloadFileWithOptionGET:nil withInferface:res.lrc savedPath:savedPath downloadSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//            //
//            //            NSArray *lirsi = [[ZYLrcLine lrcLinesWithFileName:savedPath] copy];
//            //            self.lyricTVC.array = [lirsi copy];
//            //            MYLog(@"%@",self.lyricTVC.array );
//            //            [self.lyricTVC.tableView reloadData];
//            //
//            //        NSLog(@"success");
//            //    } downloadFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            //        
//            //    } progress:^(float progress) {
//            //        
//            //    }];
//            //    
//            [weakself.player playMusic:[NSURL URLWithString:singleres.url]];
//            //[self.lyricTVC.tableView reloadData];
//            [weakself.player play];
//            
//            
//        } questFailer:^(id responseObject) {
//            
//        } questError:^(NSError *error) {
//            
//        }];
//        //添加到历史 不添加也没关系
//      [HT_API_HTTP addHistory:1 WithMid:self.musicID questSuccess:^(id responseObject) {
//          MYLog(@"hitory添加成功");
//      } questFailer:^(id responseObject) {
//          MYLog(@"hitory添加失败");
//      } questError:^(NSError *error) {
//          MYLog(@"hitory请求失败");
//      }];
    self.player.setProgressBlock = ^(double progress){
        [weakself.progress setProgress:progress animated:YES];
    };
    self.player.setSliderBlock = ^(double slide){
        [weakself.slider setValue:slide animated:YES];
    };
    self.player.setTableViewBlock = ^(NSArray *array,NSIndexPath *index,NSArray *lyrics){
        //防止刚进来就被调用 然后不能使用了
        weakself.lyricTVC.array = lyrics;
        [weakself.lyricTVC.tableView reloadRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationNone];
        [weakself.lyricTVC.tableView scrollToRowAtIndexPath:index atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    };
    }
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
     //MYLog(@"ViewWillApper");
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //MYLog(@"ViewWillDisApper");
   // [self.player pause];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
-(void)dealloc{
   // MYLog(@"playIngVCDealloc");
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
-(void)CirCleClick{
    NSLog(@"循环");
}
-(void)lastBtnClick{
    NSLog(@"上一首");
}
-(void)nextBtnClick{
    NSLog(@"下一首");
}
-(void)playOrPauseBtnClick:(UIButton *)btn{
    NSLog(@"播放或者暂停");
    if ([btn.titleLabel.text isEqualToString:@"播放"]) {
        [btn setTitle:@"暂停" forState:UIControlStateNormal];
        [self.player pause];
    }else{
        [btn setTitle:@"播放" forState:UIControlStateNormal];
         [self.player play];
    }
}
-(void)slideValueChange:(UISlider *)slider{
     [self.player pause];
    float current = (float)(self.player.totalMovieDuration * slider.value);
    // 剩余
    float remainSeconds = self.player.totalMovieDuration - current;
    CMTime currentTime = CMTimeMake(current, 1);
    //  给avplayer设置进度
   [self.player.player seekToTime:currentTime completionHandler:^(BOOL finished) {
   [self.player play];
   }];
}
@end
