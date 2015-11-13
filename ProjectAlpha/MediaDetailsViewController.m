//
//  MediaDetailsViewController.m
//  ProjectAlpha
//
//  Created by lanou3g on 15/10/26.
//  Copyright © 2015年 com.sunshuaiqi. All rights reserved.
//

#import "MediaDetailsViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import "MoviePlayerModel.h"
#import <AVOSCloud.h>
#import "LoginViewController.h"
#import "FavoriteHandle.h"
#import "FavoriteModel.h"
#import "ProjectAlpha-Swift.h"
#import <SVProgressHUD.h>

@interface MediaDetailsViewController ()
@property(nonatomic,strong)NSString * movieUrlStr;
@property (nonatomic,strong)MoviePlayerModel * movieModel;
@property (nonatomic,strong)AVPlayerViewController *moviePlayerController;
@property (nonatomic,strong)NSMutableArray *urlArray;//存放播放链接
@property (nonatomic,strong)AVPlayer *player;
@property (nonatomic,strong)AVPlayerItem  *playerItem;
@property (nonatomic,strong)UIImageView *movieImgView;
@property (nonatomic,strong)AVPlayerLayer *playerLayer;//播放器的layer
@property (nonatomic,assign)NSInteger count;//字典中对应的video
@property (nonatomic,strong)UIScrollView *scrolleView;//
@property (nonatomic,assign)BOOL isPlaying;//判断当前播放器是否正在播放
@end

@implementation MediaDetailsViewController

#pragma mark - 懒加载-
//懒加载
- (MoviePlayerModel *)movieModel
{
    if (!_movieModel) {
        
        _movieModel = [MoviePlayerModel new];
    }
    return _movieModel;
}
- (NSMutableArray *)urlArray
{
    if (!_urlArray) {
        
        _urlArray = [NSMutableArray array];
    }
    return _urlArray;
}

#pragma mark- 网络监测---
- (void)NetworkMonitoring
{
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        switch (status) {
            case AFNetworkReachabilityStatusNotReachable: {
                
                break;
            }
            case AFNetworkReachabilityStatusReachableViaWWAN: {
                [self.moviePlayerController.player pause];
                UIAlertController * alter = [UIAlertController alertControllerWithTitle:@"温情提示" message:@"当前处于非WiFi状态,是否继续播放？" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction * action1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
                UIAlertAction * action2 = [UIAlertAction actionWithTitle:@"继续" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                    // 
                    [self.moviePlayerController.player play];
                    
                }];
                [alter addAction:action1];
                [alter addAction:action2];
                [self presentViewController:alter animated:YES completion:nil];
                
                break;
            }
            case AFNetworkReachabilityStatusReachableViaWiFi: {
               
                break;
            }
            default:
                break;
        }
    }];
    
    // 开始监控
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
}

-(void)viewDidLoad

{
    [super viewDidLoad];
    self.count = 0;
    //设置返回键
    self.view.backgroundColor = [UIColor clearColor];
    UIBarButtonItem * LBI = [[UIBarButtonItem alloc] initWithImage:[AlphaIcons imageOfBackArrowWithFrame:CGRectMake(0, 0, 30, 30)]  style:UIBarButtonItemStylePlain target:self action:@selector(didClickLBI:)];
    LBI.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = LBI;
    //把是否点击收藏设置为默认的NO
    [FavoriteHandle sharedHandle].isViaClickFavorite = NO;
    // 接收登录成功的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess:) name:@"userLogIn" object:nil];
    // 收藏
    UIBarButtonItem *RBI = [[UIBarButtonItem alloc] initWithImage:[AlphaIcons imageOfFavoriteModernizedWithFrame:CGRectMake(0, 0, 25, 25)] style:UIBarButtonItemStylePlain target:self action:@selector(didCliccFavoriteBI)];
    RBI.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = RBI;
    
    //self.navigationController.navigationBar.barTintColor = [UIColor ]
    if ([userDefaults boolForKey:@"isNightMode"]) {
        self.navigationController.navigationBar.barTintColor = NightBackgroundColor;
    }else {
       if ([userDefaults colorForKey:@"dark"]) {
        self.navigationController.navigationBar.barTintColor = [userDefaults colorForKey:@"dark"];
    }
       
       //else{
        // self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
    }
#pragma mark ---解析数据
    
    self.scrolleView = [UIScrollView new];
        [self.view addSubview:self.scrolleView];
    [self.scrolleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.and.right.bottom.equalTo(self.view);
    }];
    self.scrolleView.contentSize = CGSizeMake(ScreenWidth,ScreenHeight*1.2);
    self.scrolleView.backgroundColor = [UIColor whiteColor];
    
    if ([userDefaults boolForKey:@"isNightMode"]) {
        
        self.scrolleView.backgroundColor = NightBackgroundColor;
        
    }else {
        
        if ([userDefaults colorForKey:@"light"]) {
            
            self.scrolleView.backgroundColor = [userDefaults colorForKey:@"light"];
            
        }
        
    }
    [self getData];
}
#pragma mark- 点击收藏--
- (void)didCliccFavoriteBI
{
    // 用户已经登录直接收藏
    if ([AVUser currentUser]) {
        
        NSMutableArray * modelArray = [NSMutableArray array];
        NSArray * array = [[FavoriteHandle sharedHandle] qureyData];
        for (FavoriteModel * model in array) {
            
            if ([model.ID isEqualToString:self.movieID]) {
                
                [modelArray addObject:model];
                
                [SVProgressHUD showSuccessWithStatus:@"已经收藏过了" maskType:SVProgressHUDMaskTypeBlack];
                [FavoriteHandle sharedHandle].isViaClickFavorite = NO;
            }
        }
        
        
        if (modelArray.count == 0) {
            
            [[FavoriteHandle sharedHandle] insertDataWithID:self.movieID title:self.navigationItem.title imgUrl:self.movieImgUrl paragraph:@"movie"];
            
            [SVProgressHUD showSuccessWithStatus:@"收藏成功" maskType:SVProgressHUDMaskTypeGradient];
            
            [FavoriteHandle sharedHandle].isViaClickFavorite = NO;
        }
        
    }else {
        
        // 未登录先登录后收藏
        UIAlertController * alter = [UIAlertController alertControllerWithTitle:@"温情提示" message:@"亲，登录后才能收藏哦" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * action1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction * action2 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            // 登录
            LoginViewController * loginVC = [LoginViewController new];
            [self.navigationController pushViewController:loginVC animated:YES];
            
        }];
        [alter addAction:action1];
        [alter addAction:action2];
        [self presentViewController:alter animated:YES completion:nil];
        
        [FavoriteHandle sharedHandle].isViaClickFavorite = YES;
    }
}
#pragma mark- 登录成功--
- (void)loginSuccess:(NSNotification *)notification
{
    
    
    if ([FavoriteHandle sharedHandle].isViaClickFavorite == YES) {
        
        [self didCliccFavoriteBI]; // 登录成功进入收藏
    }

    
    
}

#pragma mark -- 创建视频播放器

- (void)themeColorUpdate:(NSNotification*)notification
{
    self.view.backgroundColor = notification.userInfo[@"light"];
}

#pragma mark -- 返回事件
- (void)didClickLBI:(UIBarButtonItem *)LBI
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)dealloc
{
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"allowLandscape"];
    [self.moviePlayerController removeObserver:self forKeyPath:@"readyForDisplay"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"allowLandscape"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

#pragma mark- 获取数据
- (void)getData
{
    NSString * urlStr = [NSString stringWithFormat:@"http://mobile.open.163.com/movie/%@/getMoviesForAndroid.htm",self.movieID];
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes  = [NSSet setWithObjects:@"text/html",@"charset=utf-8", nil];
    NSDictionary * parament = @{@"Server":@"nginx"};
    [manager GET:urlStr parameters:parament success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSDictionary * dic = responseObject;
        [self.movieModel setValuesForKeysWithDictionary:dic];
        //遍历model的videoList数组
        
        for (int i = 0 ; i < self.movieModel.videoList.count;i++ ) {
            
            NSDictionary * dict = self.movieModel.videoList[i];
            if ([dic[@"mid"]isEqualToString:self.midid]) {
                self.count =i;
                [self.urlArray addObject:dict[@"repovideourlmp4"]];
            }else{
                
                [self.urlArray addObject:dict[@"repovideourlmp4"]];
                
            }
        }
        
        if (self.urlArray.count != 0) {
           self.movieUrlStr = self.urlArray[0];
        }
         self.navigationItem.title = self.movieModel.title;
        self.moviePlayerController = [[AVPlayerViewController alloc] init];
        [self.scrolleView addSubview:self.moviePlayerController.view];
        [self.moviePlayerController.view mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.top.equalTo(self.scrolleView.mas_top);
            make.left.and.right.equalTo(self.view);
            make.height.mas_equalTo(300);
            
        }];
        /**
         *  接收屏幕旋转的通知
         *  @param deviceDidRotate: 屏幕旋转的方法
         *  @return
         */
        /**
         *  修改本地和数据库中的key为yes设置appdelegate中允许横屏为yes
         */
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"allowLandscape"];

         [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceDidRotate:) name:UIDeviceOrientationDidChangeNotification object:nil];
        self.movieImgView = [UIImageView new];
        [self.movieImgView sd_setImageWithURL:[NSURL URLWithString:self.movieImgUrl]];
        self.movieImgView.frame = CGRectMake(0, 0, self.view.frame.size.width, 300);
        //打开imgview的交互
     // self.movieImgView.userInteractionEnabled = YES;
        self.movieImgView.alpha = 1.0;
        [self.moviePlayerController addObserver:self forKeyPath:@"readyForDisplay" options:NSKeyValueObservingOptionNew context:nil];
        self.playerItem = [[AVPlayerItem alloc] initWithURL:[NSURL URLWithString:self.movieUrlStr]];
        self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
        self.moviePlayerController.player = self.player;
        //[self.moviePlayerController.contentOverlayView addSubview:self.movieImgView];
        [self initSubviews];
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        
    }];
}

- (void)initSubviews
{
    
    UILabel * title = [UILabel new];
    title.text = @"简介";
    title.textAlignment = NSTextAlignmentCenter;
    title.font = [UIFont systemFontOfSize:19];
    [self.scrolleView addSubview:title];
    [title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.moviePlayerController.view.mas_bottom);
        make.centerX.equalTo(self.view);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(30);
    }];
    
    UILabel * titleLabel = [UILabel new];
    titleLabel.text = @"标题:";
    [self.view addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(title.mas_bottom);
        make.left.equalTo(self.view);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(30);
    }];
    //标题
    UILabel * titleContentLabel = [UILabel new];
    titleContentLabel.text = self.movieModel.title;
    [self.view addSubview:titleContentLabel];
    [titleContentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(titleLabel.mas_right);
        make.right.mas_equalTo(self.view).offset(-10);
        make.height.mas_equalTo(30);
        make.top.equalTo(title.mas_bottom);
    }];
    
    UILabel * category = [UILabel new];
    category.text = @"分类:";
    [self.view addSubview:category];
    [category mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom);
        make.left.equalTo(self.view);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(30);
    }];
    //分类
    UILabel * categoryContent = [UILabel new];
    categoryContent.text = self.movieModel.tags;
    [self.view addSubview:categoryContent];
    [categoryContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom);
        make.left.equalTo(category.mas_right);
        make.right.equalTo(self.view.mas_right);
        make.height.mas_equalTo(30);
        
    }];
    
    UILabel * desc = [UILabel new];
    desc.text = @"描述:";
    [self.view addSubview:desc];
    [desc mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(category.mas_bottom);
        make.left.equalTo(self.view);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(30);
    }];
    
    //描述
    UITextView * textView = [UITextView new];
    textView.text = [NSString stringWithFormat:@"      %@",self.movieModel.desc];
    textView.font = [UIFont systemFontOfSize:17];
    textView.editable = NO;
    [self.view addSubview:textView];
    textView.backgroundColor = self.scrolleView.backgroundColor;
    [textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(desc.mas_bottom);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
        
    }];
    if ([userDefaults boolForKey:@"isNightMode"]) {
        
        titleLabel.textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        titleContentLabel.textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        category.textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        categoryContent.textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        desc.textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        textView.textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    }

}
#pragma mark- 横竖屏下执行的方法----
-(void)deviceDidRotate:(NSNotification *)notification
{
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight | [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft) {  // 如果是左右横向
         self.movieImgView.frame = CGRectMake(0, 0, self.view.frame.size.width, 200);
        
            }else{ // 如果是竖屏
 
             self.movieImgView.frame = CGRectMake(0, 0, ScreenWidth, 300);
                
}

    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"readyForDisplay"]) {
        
        self.movieImgView.hidden = YES;
        print(@"开始播放了！");
    }
}

@end
