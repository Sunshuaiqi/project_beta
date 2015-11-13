//
//  ProfileViewController.m
//  ProjectAlpha
//
//  Created by lanou3g on 10/22/15.
//  Copyright © 2015 com.sunshuaiqi. All rights reserved.
//

#import "ProfileViewController.h"
#import "UIButton+ButtonFactory.h"
#import "UILabel+LabelFactory.h"
#import "SideBarViewController.h"
#import <LeanCloudFeedback/LeanCloudFeedback.h>
#import "LoginViewController.h"
#import "LBHamburgerButton.h"
#import "DataHandle.h"
#import "ProjectAlpha-Swift.h"
#import "HistoryViewController.h"
#import "FavoriteTableViewController.h"
#import "ProfileViewControllerModernized.h"
#import "HintsPage.h"
#import "QualityWebPageViewController.h"

typedef enum : NSUInteger {
    ButtonTouchDown,
    ButtonTouchUp
} ButtonActionType;

@interface ProfileViewController ()<UIGestureRecognizerDelegate,UIScrollViewDelegate,SideBarViewControllerDelegate>

#pragma mark SideBar
@property(nonatomic, strong) SideBarViewController *sideBarVC;
@property(nonatomic, strong) HintsPage *intro;
#pragma mark Buttons
@property(nonatomic, strong) UIButton *portraitButton;
@property(nonatomic, strong) UIButton *feedbackButton;
@property(nonatomic, strong) UIButton *favoriteButton;
@property(nonatomic, strong) UIButton *historyButton;
@property(nonatomic, strong) UIButton *shareButton;
@property(nonatomic, strong) UIButton *settingsButton;

@property(nonatomic, strong) UIButton *portraitIcon0;
@property(nonatomic, strong) UIButton *portraitIcon1;
@property(nonatomic, strong) UIButton *portraitIcon2;
@property(nonatomic, strong) UIButton *portraitIcon3;
@property(nonatomic, strong) UIButton *portraitIcon4;
@property(nonatomic, strong) UILabel *portraitLabel;
@property(nonatomic, strong) LBHamburgerButton* navigationBarButton;

#pragma mark SubButtons
@property(nonatomic, strong) UIButton *nightModeButton;
@property(nonatomic, strong) UIButton *themeColorButton;
@property(nonatomic, strong) UIButton *cleanCacheButton;
@property(nonatomic, strong) UIButton *wechatButton;
@property(nonatomic, strong) UIButton *weiboButton;
@property(nonatomic, strong) UIButton *maskView;

#pragma mark gesture recognizer
@property(nonatomic, strong) UIScreenEdgePanGestureRecognizer *panGestureRecognizer;

#pragma mark Parameters
@property(nonatomic, assign) BOOL settingsWasShown;
@property(nonatomic, assign) BOOL shareingWasShwon;
@property(nonatomic, assign) BOOL colorPickerWasShwon;
@property(nonatomic, assign) BOOL isChoosingIcon;
@property(nonatomic, assign) BOOL alertLock;
@property(nonatomic, strong) NSTimer *animateTimer;
@property(nonatomic, assign) float offsetFactor;
@property(nonatomic, strong) NSArray *colorsArray;
@property(nonatomic, strong) NSArray *portraitButtonArray;
@property(nonatomic, strong) AVUser *currentUser;

@end

#pragma mark- Implementation
@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLoggedInResponse:) name:@"userLogIn" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLoggedOutResponse) name:@"userLogOut" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleSideBar) name:@"toggleSideBar" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeColorUpdate:) name:@"themeColorUpdate" object:nil];
    
    _panGestureRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(edgeAction:)];
    [_panGestureRecognizer setDelegate:self];
    [_panGestureRecognizer setEdges:UIRectEdgeLeft];
    [self.view addGestureRecognizer:_panGestureRecognizer];
    
    _offsetFactor = (118 / 375.0) * self.view.frame.size.width;
    _currentUser = [AVUser currentUser];
    
    [self initializeSubViews]; // 初始化子视图
    [self setNavigationButtonWithColor:[UIColor whiteColor]];
}

- (void)introPage{
    if ([userDefaults boolForKey:@"isFirstLaunch"] == NO) {
        _intro = [[HintsPage alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
        _intro.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_intro];
        [self.view sendSubviewToBack:_intro];
        [userDefaults setBool:YES forKey:@"isFirstLaunch"];
    }else if (_intro){
        [_intro removeFromSuperview];
        _intro = nil;
    }
}

- (void)initializeSubViews{
    
    #pragma mark Portrait Button Setup
    _portraitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    _portraitButton.layer.cornerRadius = 0.32 * self.view.frame.size.width / 2;
    _portraitButton.clipsToBounds = YES;
    _portraitButton.layer.borderWidth = 1;
    _portraitButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [_portraitButton addTarget:self action:@selector(portraitButtonUp:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_portraitButton];
    
    #pragma mark Surrounding Buttons
    _feedbackButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _favoriteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _historyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [self.view addSubview:_feedbackButton];
    [self.view addSubview:_favoriteButton];
    [self.view addSubview:_historyButton];
    [self.view addSubview:_shareButton];
    [self.view addSubview:_settingsButton];
    
    #pragma mark Button Tags
    _feedbackButton.tag = 100;
    _favoriteButton.tag = 101;
    _historyButton.tag = 102;
    _shareButton.tag = 103;
    _settingsButton.tag = 105;
    
    #pragma mark Button Targets
    [_feedbackButton addTarget:self action:@selector(buttonTouchDown:) forControlEvents:UIControlEventTouchDown];
    [_favoriteButton addTarget:self action:@selector(buttonTouchDown:) forControlEvents:UIControlEventTouchDown];
    [_historyButton addTarget:self action:@selector(buttonTouchDown:) forControlEvents:UIControlEventTouchDown];
    [_shareButton addTarget:self action:@selector(buttonTouchDown:) forControlEvents:UIControlEventTouchDown];
    [_settingsButton addTarget:self action:@selector(buttonTouchDown:) forControlEvents:UIControlEventTouchDown];
    [_feedbackButton addTarget:self action:@selector(buttonTouchUp:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside];
    [_favoriteButton addTarget:self action:@selector(buttonTouchUp:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside];
    [_historyButton addTarget:self action:@selector(buttonTouchUp:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside];
    [_shareButton addTarget:self action:@selector(buttonTouchUp:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside];
    [_settingsButton addTarget:self action:@selector(buttonTouchUp:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside];
    
    [_portraitButton mas_remakeConstraints:^(MASConstraintMaker *make){
        if (is_iPhone4 | is_iPhone5){
            make.centerX.equalTo(self.view);
            make.centerY.mas_equalTo(self.view.mas_centerY).offset(- 14);
        }else{
            make.centerX.mas_equalTo(self.view);
            make.centerY.mas_equalTo(self.view.mas_centerY);
        }
        make.size.mas_equalTo(0.32 * self.view.frame.size.width);
    }];
    [self spreadFunctionButtons];
}

-(void)viewWillAppear:(BOOL)animated{
    
    if ([userDefaults boolForKey:@"isNightMode"]) {
        self.tabBarController.tabBar.barTintColor = NightBackgroundColor;
    }else if ([userDefaults colorForKey:@"dark"]) {
        self.tabBarController.tabBar.barTintColor = [userDefaults colorForKey:@"dark"];
    }
    if ([_currentUser objectForKey:@"icon"]) {
        [_portraitButton setImage:[UIImage imageWithData:[_currentUser objectForKey:@"icon"]] forState:UIControlStateNormal];
    }else{
        [_portraitButton setImage:[UIImage imageNamed:@"defaultPortrait"] forState:UIControlStateNormal];
    }

#pragma mark Side Bar
    _sideBarVC = [SideBarViewController new];
    [self addChildViewController:_sideBarVC];
    _sideBarVC.view.frame = CGRectMake(CGRectGetMinX(self.view.frame) - CGRectGetWidth(self.view.frame)* 0.4, CGRectGetMaxY(self.navigationController.navigationBar.frame), CGRectGetWidth(self.view.frame)* 0.4, CGRectGetHeight(self.view.frame) - CGRectGetHeight(self.navigationController.navigationBar.frame));
    _sideBarVC.nameLabel.text = [AVUser currentUser].username;
    
    [self.view addSubview:_sideBarVC.view];
    [_sideBarVC.portraitButton setImage:self.portraitButton.imageView.image forState:UIControlStateNormal];
    [self.navigationController.navigationBar lt_setTranslationY:0];
}

-(void)viewDidAppear:(BOOL)animated{
    
    self.sideBarVC.delegate = self;
    [self introPage];
    // 添加按钮标文
    if (!_portraitLabel) {
        _portraitLabel = [UILabel new];
        _portraitLabel.textAlignment = NSTextAlignmentCenter;
        if (_currentUser) {
            _portraitLabel.text = _currentUser.username;
        }else{
            _portraitLabel.text = @"点击登录";
        }
        _portraitLabel.textColor = [UIColor whiteColor];
        _portraitLabel.backgroundColor = [UIColor colorWithRed:0.0 green:0.502 blue:1.0 alpha:0.6];
        
        [_portraitButton addSubview:_portraitLabel];
        [_portraitLabel mas_makeConstraints:^(MASConstraintMaker *make){
            make.bottom.equalTo(_portraitButton).offset(-5);
            make.centerX.equalTo(_portraitButton);
            make.width.equalTo(_portraitButton);
            make.height.mas_equalTo(_portraitButton.frame.size.height *0.2);
        }];
    }
    [userDefaults setValue:@"profile" forKey:@"caller"]; // 当前调用该方法的控制器
    [userDefaults synchronize];
    
    [_settingsButton setImage:[AlphaIcons imageOfSettingsWithFrame:CGRectMake(0, 0, CGRectGetWidth(_settingsButton.frame), CGRectGetHeight(_settingsButton.frame))] forState:UIControlStateNormal];
    [_shareButton setImage:[AlphaIcons imageOfShareWithFrame:CGRectMake(0, 0, CGRectGetWidth(_shareButton.frame), CGRectGetWidth(_shareButton.frame))] forState:UIControlStateNormal];
    [_historyButton setImage:[AlphaIcons imageOfHistoryWithFrame:CGRectMake(0, 0, CGRectGetWidth(_historyButton.frame), CGRectGetHeight(_historyButton.frame))] forState:UIControlStateNormal];
    [_favoriteButton setImage:[AlphaIcons imageOfFavoriteWithFrame:CGRectMake(0, 0, CGRectGetWidth(_favoriteButton.frame), CGRectGetHeight(_favoriteButton.frame))] forState:UIControlStateNormal];
    [_feedbackButton setImage:[AlphaIcons imageOfFeedBackWithFrame:CGRectMake(0, 0, CGRectGetWidth(_feedbackButton.frame), CGRectGetHeight(_feedbackButton.frame))] forState:UIControlStateNormal];
    
}

- (void)spreadFunctionButtons{
    
    [_settingsButton mas_remakeConstraints:^(MASConstraintMaker *make){
        make.centerX.equalTo(_portraitButton.mas_centerX).offset(_offsetFactor *cos(333 / 180.0 *M_PI));
        make.centerY.equalTo(_portraitButton.mas_centerY).offset( _offsetFactor *sin(333 / 180.0 * M_PI));
        make.size.mas_equalTo(0.22 *self.view.frame.size.width);
    }];
    [_favoriteButton mas_remakeConstraints:^(MASConstraintMaker *make){
        make.centerX.equalTo(_portraitButton.mas_centerX).offset( _offsetFactor *cos(261 / 180.0 *M_PI));
        make.centerY.equalTo(_portraitButton.mas_centerY).offset( _offsetFactor *sin(261 / 180.0 * M_PI));
        make.size.mas_equalTo(0.22 * self.view.frame.size.width);
    }];
    [_historyButton mas_remakeConstraints:^(MASConstraintMaker *make){
        make.centerX.equalTo(_portraitButton.mas_centerX).offset( _offsetFactor *cos(189/180.0 *M_PI));
        make.centerY.equalTo(_portraitButton.mas_centerY).offset( _offsetFactor *sin(189/180.0 *M_PI));
        make.size.mas_equalTo(0.22 * self.view.frame.size.width);
    }];
    [_shareButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_portraitButton.mas_centerX).offset(_offsetFactor * cos(117/180.0 * M_PI));
        make.centerY.equalTo(_portraitButton.mas_centerY).offset( _offsetFactor * sin(117/180.0 * M_PI));
        make.size.mas_equalTo(0.22 * self.view.frame.size.width);
    }];
    [_feedbackButton mas_remakeConstraints:^(MASConstraintMaker *make){
        // X中心 = cos(º / 180 * π)           Y中心 = sin(º / 180 * π)
        make.centerX.equalTo(_portraitButton.mas_centerX).offset( _offsetFactor *cos(45/180.0 * M_PI));
        make.centerY.equalTo(_portraitButton.mas_centerY).offset( _offsetFactor *sin(45/180.0 * M_PI));
        make.size.mas_equalTo(0.22 * self.view.frame.size.width);
    }];
    
    _feedbackButton.alpha = 1;
    _favoriteButton.alpha = 1;
    _historyButton.alpha = 1;
    _shareButton.alpha = 1;
    _settingsButton.alpha = 1;
    
}

- (void)contractFuctionButtons{
     if (_settingsWasShown) {
        [self settingsDismiss];
    }
    if (_shareingWasShwon) {
        [self shareingDismiss];
    }
        [_feedbackButton mas_remakeConstraints:^(MASConstraintMaker *make){
            make.size.equalTo(_portraitButton);
            make.center.equalTo(_portraitButton);
        }];
        [_favoriteButton mas_remakeConstraints:^(MASConstraintMaker *make){
            make.size.equalTo(_portraitButton);
            make.center.equalTo(_portraitButton);
        }];
        [_historyButton mas_remakeConstraints:^(MASConstraintMaker *make){
            make.size.equalTo(_portraitButton);
            make.center.equalTo(_portraitButton);
        }];
        [_shareButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(_portraitButton);
            make.center.equalTo(_portraitButton);
        }];
        [_settingsButton mas_remakeConstraints:^(MASConstraintMaker *make){
            make.size.equalTo(_portraitButton);
            make.center.equalTo(_portraitButton);
        }];
        
        _feedbackButton.alpha = 0;
        _favoriteButton.alpha = 0;
        _historyButton.alpha = 0;
        _shareButton.alpha = 0;
        _settingsButton.alpha = 0;
        [self.view layoutIfNeeded];
    [self.view bringSubviewToFront:_portraitButton];
}

- (void)spreadPortraitIcons{
    if (!_portraitIcon0 && !_portraitIcon1) {
        
        _isChoosingIcon = YES;
        
        _portraitIcon0 = [UIButton roundButtonWithImage:[UIImage imageNamed:@"portrait"] PlacedAtButton:_portraitButton addToView:self.view];
        _portraitIcon1 = [UIButton roundButtonWithImage:[UIImage imageNamed:@"portrait1"] PlacedAtButton:_portraitButton addToView:self.view];
        _portraitIcon2 = [UIButton roundButtonWithImage:[UIImage imageNamed:@"portrait2"] PlacedAtButton:_portraitButton addToView:self.view];
        _portraitIcon3 = [UIButton roundButtonWithImage:[UIImage imageNamed:@"portrait3"] PlacedAtButton:_portraitButton addToView:self.view];
        _portraitIcon4 = [UIButton roundButtonWithImage:[UIImage imageNamed:@"portrait4"] PlacedAtButton:_portraitButton addToView:self.view];
        
        [self slideOutAnimationWithButton:_portraitIcon0 Angle:180 fromView:_portraitButton Distance:130 AfterDelay:0.0 Size:100];
        [self slideOutAnimationWithButton:_portraitIcon1 Angle:110 fromView:_portraitButton Distance:130 AfterDelay:0.05 Size:100];
        [self slideOutAnimationWithButton:_portraitIcon2 Angle:40 fromView:_portraitButton Distance:130 AfterDelay:0.1 Size:100];
        [self slideOutAnimationWithButton:_portraitIcon3 Angle:-30 fromView:_portraitButton Distance:130 AfterDelay:0.15 Size:100];
        [self slideOutAnimationWithButton:_portraitIcon4 Angle:-100 fromView:_portraitButton Distance:130 AfterDelay:0.2 Size:100];
        
        [_portraitIcon0 addTarget:self action:@selector(didFinishPickingPortraitIcon:) forControlEvents:UIControlEventTouchUpInside];
        [_portraitIcon1 addTarget:self action:@selector(didFinishPickingPortraitIcon:) forControlEvents:UIControlEventTouchUpInside];
        [_portraitIcon2 addTarget:self action:@selector(didFinishPickingPortraitIcon:) forControlEvents:UIControlEventTouchUpInside];
        [_portraitIcon3 addTarget:self action:@selector(didFinishPickingPortraitIcon:) forControlEvents:UIControlEventTouchUpInside];
        [_portraitIcon4 addTarget:self action:@selector(didFinishPickingPortraitIcon:) forControlEvents:UIControlEventTouchUpInside];
        
        if (_sideBarVC.view) { // 判断如果此时侧边栏存在 则侧边栏至于顶部显示 不被遮盖
            [self.view bringSubviewToFront:_sideBarVC.view];
        }
        _portraitButtonArray = @[_portraitIcon0, _portraitIcon1, _portraitIcon2, _portraitIcon3, _portraitIcon4];
    }
    
}


- (void)buttonTouchDown:(UIButton *)sender{
    
    switch (sender.tag) {
        case 100:
            [self bouceWithButton:sender Size:0.22 ActionType:ButtonTouchDown];
            break;
            
        case 101:
            [self bouceWithButton:sender Size:0.22 ActionType:ButtonTouchDown];
            break;
            
        case 102:
            [self bouceWithButton:sender Size:0.22 ActionType:ButtonTouchDown];
            break;
            
        case 103:
            [self bouceWithButton:sender Size:0.22 ActionType:ButtonTouchDown];
            
            if (!_shareingWasShwon) {
#pragma mark wecatButton
                _wechatButton = [UIButton buttonWithType:UIButtonTypeCustom];
                _wechatButton.frame = CGRectMake(CGRectGetMidX(_shareButton.frame) - 0.20 * self.view.frame.size.width /2, CGRectGetMidY(_shareButton.frame) - 0.20 * self.view.frame.size.width / 2, 0.20 * self.view.frame.size.width, 0.20 * self.view.frame.size.width);
                [_wechatButton addTarget:self action:@selector(incomplete) forControlEvents:UIControlEventTouchUpInside];
                [self.view addSubview:_wechatButton];
                [_wechatButton setBackgroundImage:[AlphaIcons imageOfDefaultBorderWithFrame:CGRectMake(0, 0, CGRectGetWidth(_wechatButton.frame), CGRectGetHeight(_wechatButton.frame))] forState:UIControlStateNormal];
                [_wechatButton setTitle:@"微信分享" forState:UIControlStateNormal];
                
                if ([userDefaults boolForKey:@"isNightMode"]){
                    [_wechatButton setTitleColor:NightTextColor forState:UIControlStateNormal];
                }else{
                    [_wechatButton setTitleColor:DayTextColor forState:UIControlStateNormal];
                }
                _wechatButton.alpha = 0.1;
                
#pragma mark weiboButton
                _weiboButton = [UIButton buttonWithType:UIButtonTypeCustom];
                _weiboButton.frame = CGRectMake(CGRectGetMidX(_shareButton.frame) - 0.20 * self.view.frame.size.width /2, CGRectGetMidY(_shareButton.frame) - 0.20 * self.view.frame.size.width / 2, 0.20 * self.view.frame.size.width, 0.20 * self.view.frame.size.width);
                [_weiboButton addTarget:self action:@selector(incomplete) forControlEvents:UIControlEventTouchUpInside];
                [self.view addSubview:_weiboButton];
                [_weiboButton setBackgroundImage:[AlphaIcons imageOfDefaultBorderWithFrame:CGRectMake(0, 0, CGRectGetWidth(_weiboButton.frame), CGRectGetHeight(_weiboButton.frame))] forState:UIControlStateNormal];
                [_weiboButton setTitle:@"微博分享" forState:UIControlStateNormal];
                if ([userDefaults boolForKey:@"isNightMode"]){
                    [_weiboButton setTitleColor:NightTextColor forState:UIControlStateNormal];
                }else{
                    [_weiboButton setTitleColor:DayTextColor forState:UIControlStateNormal];
                }
                _weiboButton.alpha = 0.1;
                if (is_iPhone4 | is_iPhone5) {
                    _weiboButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
                    _wechatButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
                }else{
                    _weiboButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
                    _wechatButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
                }
                [UIView animateWithDuration:0.3 delay:0.1 options:UIViewAnimationOptionAllowUserInteraction animations:^{
                
                    [_wechatButton mas_makeConstraints:^(MASConstraintMaker *make){
                        make.centerX.equalTo(_portraitButton.mas_centerX).offset(_offsetFactor*1.2 *cos(153 / 180.0 *M_PI));
                        make.centerY.equalTo(_portraitButton.mas_centerY).offset( _offsetFactor*1.2 *sin(153 / 180.0 * M_PI));
                        make.size.mas_equalTo(0.2 *self.view.frame.size.width);
                    }];
                    _wechatButton.alpha = 1.0;
                    
                    [self.view layoutIfNeeded];
                } completion:nil];
                
                [UIView animateWithDuration:0.3 animations:^{
                    [_weiboButton mas_makeConstraints:^(MASConstraintMaker *make){
                        make.centerX.equalTo(_portraitButton.mas_centerX).offset(_offsetFactor*1.2 *cos(81 / 180.0 *M_PI));
                        make.centerY.equalTo(_portraitButton.mas_centerY).offset( _offsetFactor*1.2 *sin(81 / 180.0 * M_PI));
                        make.size.mas_equalTo(0.2 *self.view.frame.size.width);
                    }];
                    _weiboButton.alpha = 1.0;
                    [self.view layoutIfNeeded];
                }];
                
                _shareingWasShwon = YES;
                
            } else {
                [self shareingDismiss];
            }
            
            break;
            
        case 104:
            [self bouceWithButton:sender Size:0.22 ActionType:ButtonTouchDown];
            break;
            
        case 105:
            [self bouceWithButton:sender Size:0.22 ActionType:ButtonTouchDown];
            if (!_settingsWasShown) {
                 [DataHandle SharedData].cacheCount = [[DataHandle SharedData] folderSizeAtPath:NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0]];
#pragma mark nightModeButton
                _nightModeButton = [UIButton buttonWithType:UIButtonTypeCustom];
                _nightModeButton.frame = _settingsButton.frame;
                [self.view addSubview:_nightModeButton];
                [_nightModeButton setBackgroundImage:[AlphaIcons imageOfDefaultBorderWithFrame:CGRectMake(0, 0, CGRectGetWidth(_nightModeButton.frame), CGRectGetHeight(_nightModeButton.frame))] forState:UIControlStateNormal];
                
                if ([userDefaults boolForKey:@"isNightMode"]) {
                    [_nightModeButton setTitle:@"日间模式" forState:UIControlStateNormal];
                    [_nightModeButton setTitleColor:NightTextColor forState:UIControlStateNormal];
                }else{
                    [_nightModeButton setTitle:@"夜间模式" forState:UIControlStateNormal];
                    [_nightModeButton setTitleColor:DayTextColor forState:UIControlStateNormal];
                }
                
                [_nightModeButton addTarget:self action:@selector(nightModeSwitch) forControlEvents:UIControlEventTouchUpInside];
                _nightModeButton.alpha = 0.1;
                
                if (is_iPhone4 | is_iPhone5) {
                    _nightModeButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
                }else{
                    _nightModeButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
                }
                
#pragma mark themeColorButton
                _themeColorButton = [UIButton buttonWithType:UIButtonTypeCustom];
                _themeColorButton.frame =  _settingsButton.frame;
                
                [self.view addSubview:_themeColorButton];
                if ([userDefaults boolForKey:@"isNightMode"]) {
                    [_themeColorButton setImage:[AlphaIcons imageOfThemeColorNightModeWithFrame:CGRectMake(0, 0, CGRectGetWidth(_themeColorButton.frame), CGRectGetHeight(_themeColorButton.frame))] forState:UIControlStateNormal];
                }else{
                [_themeColorButton setImage:[AlphaIcons imageOfThemeColorWithFrame:CGRectMake(0, 0, CGRectGetWidth(_themeColorButton.frame), CGRectGetHeight(_themeColorButton.frame))] forState:UIControlStateNormal];
                }
                [_themeColorButton addTarget:self action:@selector(colorPicker:) forControlEvents:UIControlEventTouchDown];
                _themeColorButton.alpha = 0.1;
                
#pragma mark cleanCacheButton
                _cleanCacheButton = [UIButton buttonWithType:UIButtonTypeCustom];
                _cleanCacheButton.frame = _settingsButton.frame;
                [self.view addSubview:_cleanCacheButton];
                [_cleanCacheButton setTitle:[NSString stringWithFormat:@"清理缓存: %.1fM",[DataHandle SharedData].cacheCount] forState:UIControlStateNormal];
                [_cleanCacheButton addTarget:self action:@selector(cleanCacheAction:) forControlEvents:UIControlEventTouchUpInside];
                
                _cleanCacheButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
                [_cleanCacheButton setBackgroundImage:[AlphaIcons imageOfBorderWithIndicatorWithFrame:CGRectMake(0, 0, CGRectGetWidth(_cleanCacheButton.frame), CGRectGetHeight(_cleanCacheButton.frame)) fraction:[DataHandle SharedData].cacheCount / 195.0 scale:is_iPhone4 ? 0.97 : (is_iPhone5? 0.97:1.15)] forState:UIControlStateNormal];
                _cleanCacheButton.alpha = 0.1;
                
                
                if ([userDefaults boolForKey:@"isNightMode"]){
                     [_cleanCacheButton setTitleColor:NightTextColor forState:UIControlStateNormal];
                }else{
                     [_cleanCacheButton setTitleColor:DayTextColor forState:UIControlStateNormal];
                }
                
                _cleanCacheButton.titleLabel.numberOfLines = 0;
                _cleanCacheButton.titleLabel.textAlignment = NSTextAlignmentCenter;
                
                [UIView animateWithDuration:0.3 delay:0.2 options:UIViewAnimationOptionAllowUserInteraction animations:^{
                    [_nightModeButton mas_makeConstraints:^(MASConstraintMaker *make){
                        make.centerX.equalTo(_portraitButton.mas_centerX).offset(_offsetFactor*1.2 *cos(9 / 180.0 *M_PI));
                        make.centerY.equalTo(_portraitButton.mas_centerY).offset( _offsetFactor*1.2 *sin(9 / 180.0 * M_PI));
                        make.size.mas_equalTo(0.2 *self.view.frame.size.width);
                    }];
                    _nightModeButton.alpha = 1.0;
                    [self.view layoutIfNeeded];
                } completion:nil];
                
                [UIView animateWithDuration:0.3 animations:^{
                    [_cleanCacheButton mas_makeConstraints:^(MASConstraintMaker *make){
                        make.centerX.equalTo(_portraitButton.mas_centerX).offset(_offsetFactor*1.2 *cos(225 / 180.0 *M_PI));
                        make.centerY.equalTo(_portraitButton.mas_centerY).offset( _offsetFactor*1.2 *sin(225 / 180.0 * M_PI));
                        make.size.mas_equalTo(0.2 *self.view.frame.size.width);
                    }];
                    _cleanCacheButton.alpha = 1.0;
                    [self.view layoutIfNeeded];
                }];
                [UIView animateWithDuration:0.3 delay:0.1 options:UIViewAnimationOptionAllowUserInteraction  animations:^{
                    [_themeColorButton mas_makeConstraints:^(MASConstraintMaker *make){
                        make.centerX.equalTo(_portraitButton.mas_centerX).offset(_offsetFactor*1.2 *cos(297 / 180.0 *M_PI));
                        make.centerY.equalTo(_portraitButton.mas_centerY).offset( _offsetFactor*1.2 *sin(297 / 180.0 * M_PI));
                        make.size.mas_equalTo(0.2 *self.view.frame.size.width);
                    }];
                    _themeColorButton.alpha = 1.0;
                    [self.view layoutIfNeeded];
                }completion:^(BOOL finished) {
                    _maskView = [UIButton buttonWithType:UIButtonTypeCustom];
                    _maskView.frame = _themeColorButton.frame;
                    _maskView.alpha = 0.0;
                    _maskView.userInteractionEnabled = YES;
                    [_maskView setBackgroundImage:[AlphaIcons imageOfMaskViewWithFrame:CGRectMake(0, 0, CGRectGetWidth(_maskView.frame), CGRectGetHeight(_maskView.frame))] forState:UIControlStateNormal];
                    [self.view addSubview:_maskView];
                    [self.view bringSubviewToFront:_themeColorButton];
                }];
                _settingsWasShown = YES;
                
            }else{
                [self settingsDismiss];
            }
            break;
    }
}

- (void)buttonTouchUp:(UIButton *)sender{
    switch (sender.tag) {
        case 100:{
            LCUserFeedbackAgent *agent = [LCUserFeedbackAgent sharedInstance];
            /* title 传 nil 表示将第一条消息作为反馈的标题。 contact 也可以传入 nil，由用户来填写联系方式。*/
            [agent showConversations:self title:@"feedback" contact:@"bugreport@appleDev.com"];
            [self bouceWithButton:sender Size:0.20 ActionType:ButtonTouchUp];
            break;
        }
            
        case 101:
            print(@"收藏")
            [self.navigationController pushViewController:[FavoriteTableViewController new] animated:YES];
            [self bouceWithButton:sender Size:0.20 ActionType:ButtonTouchUp];
            break;
            
        case 102:
            print(@"历史")
            [self.navigationController pushViewController:[HistoryViewController new] animated:YES];
            [self bouceWithButton:sender Size:0.20 ActionType:ButtonTouchUp];
            break;
            
        case 103:
            print(@"分享");
            [self bouceWithButton:sender Size:0.20 ActionType:ButtonTouchUp];
            break;
            
        case 104:
            [self.navigationController pushViewController:[QualityWebPageViewController new] animated:YES];
            [self bouceWithButton:sender Size:0.20 ActionType:ButtonTouchUp];
            break;
            
        case 105:
            [self bouceWithButton:sender Size:0.20 ActionType:ButtonTouchUp];
            print(@"设置")
            break;
            
    }
}

- (void)bouceWithButton:(UIButton *)sender Size:(CGFloat)size ActionType:(NSUInteger)actionType{
    
    if (actionType == ButtonTouchDown) {
        [UIView animateWithDuration:0.03 animations:^{
            [sender mas_updateConstraints:^(MASConstraintMaker *make){
                make.size.mas_equalTo((size-0.02) *self.view.frame.size.width);
            }];
            [self.view layoutIfNeeded];
        }];
    }
    if (actionType == ButtonTouchUp){
        [UIView animateWithDuration:0.04 animations:^{
            [sender mas_updateConstraints:^(MASConstraintMaker *make){
                make.size.mas_equalTo((size+0.02) *self.view.frame.size.width);
            }];
            [self.view layoutIfNeeded];
        }];
    }
}

- (void)colorPicker:(UIButton *)sender{
    
    if (!_colorPickerWasShwon) {
        if (_shareingWasShwon) {
            [self.view sendSubviewToBack:_weiboButton];
            [self.view sendSubviewToBack:_wechatButton];
        }
        [_maskView addTarget:self action:@selector(colorPickerCancel) forControlEvents:UIControlEventTouchUpInside];
        if ([userDefaults boolForKey:@"isNightMode"]) {
            _maskView.tintColor = NightBackgroundColor;
        }else{
            _maskView.tintColor = [UIColor whiteColor];
        }
        _maskView.adjustsImageWhenHighlighted = NO;
        [self.view bringSubviewToFront:_themeColorButton];
        sender.rotate(360).animate(0.4);
        [UIView animateWithDuration:0.5 animations:^{
            [_maskView mas_remakeConstraints:^(MASConstraintMaker *make){
                make.center.equalTo(_themeColorButton);
                make.size.mas_equalTo([UIScreen mainScreen].bounds.size.height * 2);
            }];
            _maskView.alpha = 1;
            [self.view layoutIfNeeded];
        }];
        
#pragma mark 创建颜色
        
        UIButton *pink = [UIButton roundButtonWithColor:[UIColor colorWithRed:0.9137 green:0.3255 blue:0.5137 alpha:1.0] PlacedAtButton:_themeColorButton addToView:self.view];
        [self slideOutAnimationWithButton:pink Angle:165 fromView:_themeColorButton Distance:80 AfterDelay:0.1 Size:55];
        [pink addTarget:self action:@selector(colorPickerDidFinishPickingColor:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *lightBlue = [UIButton roundButtonWithColor:[UIColor colorWithRed:0.4314 green:0.7608 blue:0.9333 alpha:1.0] PlacedAtButton:_themeColorButton addToView:self.view];
        [self slideOutAnimationWithButton:lightBlue Angle:115 fromView:_themeColorButton Distance:80 AfterDelay:0.2 Size:55];
        [lightBlue addTarget:self action:@selector(colorPickerDidFinishPickingColor:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *blue = [UIButton roundButtonWithColor:[UIColor colorWithRed:0 green:0.6863 blue:0.9412 alpha:1] PlacedAtButton:_themeColorButton addToView:self.view];
        [self slideOutAnimationWithButton:blue Angle:180 fromView:_themeColorButton Distance:150 AfterDelay:0.3 Size:55];
        [blue addTarget:self action:@selector(colorPickerDidFinishPickingColor:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *purple = [UIButton roundButtonWithColor:[UIColor colorWithRed:0.4863 green:0.3137 blue:0.6157 alpha:1.0] PlacedAtButton:_themeColorButton addToView:self.view];
        [self slideOutAnimationWithButton:purple Angle:100 + 80/3.0*2 fromView:_themeColorButton Distance:150 AfterDelay:0.4 Size:55];
        [purple addTarget:self action:@selector(colorPickerDidFinishPickingColor:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton  *brown = [UIButton roundButtonWithColor:[UIColor colorWithRed:0.6196 green:0.3098 blue:0.1176 alpha:1.0] PlacedAtButton:_themeColorButton addToView:self.view];
        [self slideOutAnimationWithButton:brown Angle:100+80/3.0 fromView:_themeColorButton Distance:150 AfterDelay:0.5 Size:55];
        [brown addTarget:self action:@selector(colorPickerDidFinishPickingColor:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *green = [UIButton roundButtonWithColor:[UIColor colorWithRed:0.1912 green:0.4227 blue:0.2569 alpha:1.0] PlacedAtButton:_themeColorButton addToView:self.view];
        [self slideOutAnimationWithButton:green Angle:100 fromView:_themeColorButton Distance:150 AfterDelay:0.6 Size:55];
        [green addTarget:self action:@selector(colorPickerDidFinishPickingColor:) forControlEvents:UIControlEventTouchUpInside];
        
        _colorsArray = @[blue, pink, green, lightBlue, brown, purple];
        _colorPickerWasShwon = YES;
    }else{
        [self colorPickerCancel];
    }
}

- (void)slideOutAnimationWithButton:(UIButton *)button Angle:(CGFloat)angle fromView:(UIView *)view Distance:(CGFloat)distance AfterDelay:(CGFloat)delay Size:(CGFloat)size{
    [UIView animateWithDuration:0.3 delay:delay options:UIViewAnimationOptionAllowUserInteraction animations:^{
        [button mas_remakeConstraints:^(MASConstraintMaker *make){
            make.centerX.equalTo(view).offset((distance / 375.0) * self.view.frame.size.width * cos(angle / 180.0 * M_PI));
            make.centerY.equalTo(view).offset((distance / 375.0) * self.view.frame.size.width * sin(angle / 180.0 * M_PI));
            make.size.mas_equalTo(size / 375.0 * self.view.frame.size.width);
        }];
        button.alpha = 1.0;
        [self.view layoutIfNeeded];
    } completion:nil];
}

- (void)colorPickerDidFinishPickingColor:(UIButton *)picked{
    
    [self.view bringSubviewToFront:picked];
    if ([userDefaults boolForKey:@"isNightMode"]) { // 如果是夜间模式
        [self nightModeSwitch];  // 转换为日间模式
    }
    if ([[userDefaults valueForKey:@"caller"] isEqualToString:@"profile"]) {
        print(@"%s line:%d %@",__PRETTY_FUNCTION__,__LINE__, [userDefaults valueForKey:@"caller"]);
        [UIView animateWithDuration:0.4 animations:^{
            [picked mas_updateConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo([UIScreen mainScreen].bounds.size.height * 1.5);
            }];
            [self.view layoutIfNeeded];
        }completion:^(BOOL finished) {
            [UIView animateWithDuration:0.2 animations:^{
                picked.alpha = 0.0;
            }completion:^(BOOL finished) {
                [picked removeFromSuperview];
            }];
        }];
        [self performSelector:@selector(colorPickerCancel) withObject:nil afterDelay:0.18];
    }
    
#pragma mark 发布主题颜色
    if ([picked.tintColor isEqual:[UIColor colorWithRed:0.9137 green:0.3255 blue:0.5137 alpha:1.0]]|[picked.backgroundColor isEqual:[UIColor colorWithRed:0.9137 green:0.3255 blue:0.5137 alpha:1.0]]) {
        print(@"选中粉色")
        [[NSNotificationCenter defaultCenter] postNotificationName:@"themeColorUpdate" object:self userInfo:@{
         @"threashold":[UIColor colorWithRed:0.9216 green:0.3804 blue:0.0706 alpha:1.0],
         @"alternative":[UIColor colorWithRed:0.9218 green:0.707 blue:0.236 alpha:1.0],
         @"light":[UIColor colorWithRed:0.9673 green:0.9259 blue:0.8066 alpha:1.0],
         @"normal":[UIColor colorWithRed:0.9333 green:0.5255 blue:0.6039 alpha:1.0],
         @"dark":[UIColor colorWithRed:0.9137 green:0.3255 blue:0.5137 alpha:1.0],
         @"color":@"pink"}];
        [userDefaults setColor:[UIColor colorWithRed:0.9216 green:0.3804 blue:0.0706 alpha:1.0] forKey:@"threashold"];
        [userDefaults setColor:[UIColor colorWithRed:0.9673 green:0.9259 blue:0.8066 alpha:1.0] forKey:@"light"];
        [userDefaults setColor:[UIColor colorWithRed:0.9333 green:0.5255 blue:0.6039 alpha:1.0] forKey:@"normal"];
        [userDefaults setColor:[UIColor colorWithRed:0.9137 green:0.3255 blue:0.5137 alpha:1.0] forKey:@"dark"];
    }else if ([picked.tintColor isEqual:[UIColor colorWithRed:0 green:0.6863 blue:0.9412 alpha:1]]|[picked.backgroundColor isEqual:[UIColor colorWithRed:0 green:0.6863 blue:0.9412 alpha:1]]){
        print(@"选中蓝色")
        [[NSNotificationCenter defaultCenter] postNotificationName:@"themeColorUpdate" object:self userInfo:@{
         @"threashold":[UIColor colorWithRed:0.0581 green:0.4755 blue:0.7963 alpha:1.0],
         @"alternative":[UIColor colorWithRed:0.5882 green:0.6863 blue:0.8588 alpha:1.0],
         @"light":[UIColor whiteColor],
         @"normal":[UIColor colorWithRed:0.3294 green:0.7647 blue:0.9451 alpha:1.0],
         @"dark":[UIColor colorWithRed:0 green:0.6863 blue:0.9412 alpha:1],
         @"color":@"blue"}];
        [userDefaults setColor:[UIColor colorWithRed:0.0581 green:0.4755 blue:0.7963 alpha:1.0] forKey:@"threashold"];
        [userDefaults setColor:[UIColor whiteColor] forKey:@"light"];
        [userDefaults setColor:[UIColor colorWithRed:0.3294 green:0.7647 blue:0.9451 alpha:1.0] forKey:@"normal"];
        [userDefaults setColor:[UIColor colorWithRed:0 green:0.6863 blue:0.9412 alpha:1] forKey:@"dark"];
    }else if ([picked.tintColor isEqual:[UIColor colorWithRed:0.1912 green:0.4227 blue:0.2569 alpha:1.0]]|[picked.backgroundColor isEqual:[UIColor colorWithRed:0.1912 green:0.4227 blue:0.2569 alpha:1.0]]){
        print(@"选中绿色")
        [[NSNotificationCenter defaultCenter] postNotificationName:@"themeColorUpdate" object:self userInfo:@{
           @"threashold":[UIColor colorWithRed:0.2018 green:0.5087 blue:0.1609 alpha:1.0],
           @"alternative":[UIColor colorWithRed:0.6075 green:0.7604 blue:0.298 alpha:1.0],
           @"light":[UIColor colorWithRed:0.8609 green:0.9277 blue:0.7653 alpha:1.0],
           @"normal":[UIColor colorWithRed:0.537 green:0.7685 blue:0.4355 alpha:1.0],
           @"dark":[UIColor colorWithRed:0.1912 green:0.4227 blue:0.2569 alpha:1.0],
           @"color":@"green"}];
        [userDefaults setColor:[UIColor colorWithRed:0.2018 green:0.5087 blue:0.1609 alpha:1.0] forKey:@"threashold"];
        [userDefaults setColor:[UIColor colorWithRed:0.8609 green:0.9277 blue:0.7653 alpha:1.0] forKey:@"light"];
        [userDefaults setColor:[UIColor colorWithRed:0.537 green:0.7685 blue:0.4355 alpha:1.0] forKey:@"normal"];
        [userDefaults setColor:[UIColor colorWithRed:0.1912 green:0.4227 blue:0.2569 alpha:1.0] forKey:@"dark"];
    }else if ([picked.tintColor isEqual:[UIColor colorWithRed:0.6196 green:0.3098 blue:0.1176 alpha:1.0]]|[picked.backgroundColor isEqual:[UIColor colorWithRed:0.6196 green:0.3098 blue:0.1176 alpha:1.0]]){
        print(@"选中棕色")
        [[NSNotificationCenter defaultCenter] postNotificationName:@"themeColorUpdate" object:self userInfo:@{
           @"threashold":[UIColor colorWithRed:0.9294 green:0.4745 blue:0.5804 alpha:1.0],
           @"alternative":[UIColor colorWithRed:0.9335 green:0.5755 blue:0.4726 alpha:1.0],
           @"light":[UIColor colorWithRed:0.9989 green:0.9429 blue:0.6658 alpha:1.0],
           @"normal":[UIColor colorWithRed:0.9707 green:0.7592 blue:0.4608 alpha:1.0],
           @"dark":[UIColor colorWithRed:0.5451 green:0.2374 blue:0.092 alpha:1.0],
           @"color":@"green"}];
        [userDefaults setColor:[UIColor colorWithRed:0.9294 green:0.4745 blue:0.5804 alpha:1.0] forKey:@"threashold"];
        [userDefaults setColor:[UIColor colorWithRed:0.9989 green:0.9429 blue:0.6658 alpha:1.0] forKey:@"light"];
        [userDefaults setColor:[UIColor colorWithRed:0.9707 green:0.7592 blue:0.4608 alpha:1.0] forKey:@"normal"];
        [userDefaults setColor:[UIColor colorWithRed:0.5451 green:0.2374 blue:0.092 alpha:1.0] forKey:@"dark"];
    }else if ([picked.tintColor isEqual:[UIColor colorWithRed:0.4863 green:0.3137 blue:0.6157 alpha:1.0]]|[picked.backgroundColor isEqual:[UIColor colorWithRed:0.4863 green:0.3137 blue:0.6157 alpha:1.0]]){
        print(@"选中紫色")
    [[NSNotificationCenter defaultCenter] postNotificationName:@"themeColorUpdate" object:self userInfo:@{
           @"threashold":[UIColor colorWithRed:0.5339 green:0.3562 blue:0.6286 alpha:1.0],
           @"alternative":[UIColor colorWithRed:0.8078 green:0.5725 blue:0.749 alpha:1.0],
           @"light":[UIColor colorWithRed:0.898 green:0.7961 blue:0.8824 alpha:1.0],
           @"normal":[UIColor colorWithRed:0.6902 green:0.6549 blue:0.8196 alpha:1.0],
           @"dark":[UIColor colorWithRed:0.4863 green:0.3137 blue:0.6157 alpha:1.0],
           @"color":@"purple"}];
        [userDefaults setColor:[UIColor colorWithRed:0.5339 green:0.3562 blue:0.6286 alpha:1.0] forKey:@"threashold"];
        [userDefaults setColor:[UIColor colorWithRed:0.898 green:0.7961 blue:0.8824 alpha:1.0] forKey:@"light"];
        [userDefaults setColor:[UIColor colorWithRed:0.6902 green:0.6549 blue:0.8196 alpha:1.0] forKey:@"normal"];
        [userDefaults setColor:[UIColor colorWithRed:0.4863 green:0.3137 blue:0.6157 alpha:1.0] forKey:@"dark"];
    }else if ([picked.tintColor isEqual:[UIColor colorWithRed:0.4314 green:0.7608 blue:0.9333 alpha:1.0]]|[picked.backgroundColor isEqual:[UIColor colorWithRed:0.4314 green:0.7608 blue:0.9333 alpha:1.0]]){
        print(@"选中浅蓝色")
        [[NSNotificationCenter defaultCenter] postNotificationName:@"themeColorUpdate" object:self userInfo:@{
          @"threashold":[UIColor colorWithRed:0.159 green:0.6676 blue:0.6418 alpha:1.0],
          @"alternative":[UIColor colorWithRed:0.575 green:0.8115 blue:0.7925 alpha:1.0],
          @"light":[UIColor colorWithRed:0.8515 green:0.9323 blue:0.9457 alpha:1.0],
          @"normal":[UIColor colorWithRed:0.6776 green:0.8291 blue:0.9453 alpha:1.0],
          @"dark":[UIColor colorWithRed:0.3674 green:0.7074 blue:0.9156 alpha:1.0],
          @"color":@"mint"}];
        [userDefaults setColor:[UIColor colorWithRed:0.159 green:0.6676 blue:0.6418 alpha:1.0] forKey:@"threashold"];
        [userDefaults setColor:[UIColor colorWithRed:0.8515 green:0.9323 blue:0.9457 alpha:1.0] forKey:@"light"];
        [userDefaults setColor:[UIColor colorWithRed:0.6776 green:0.8291 blue:0.9453 alpha:1.0] forKey:@"normal"];
        [userDefaults setColor:[UIColor colorWithRed:0.3674 green:0.7074 blue:0.9156 alpha:1.0] forKey:@"dark"];
    }
}

- (void)didFinishPickingPortraitIcon:(UIButton *)sender{
    _isChoosingIcon = NO;
    
        [UIView animateWithDuration:0.3 animations:^{
            for (UIButton *button in _portraitButtonArray) {
                if (button != sender) {
                    button.alpha = 0;
                }
            }
            if (sender) {
            [sender mas_updateConstraints:^(MASConstraintMaker *make){
                make.size.mas_equalTo(0.32 * self.view.frame.size.width);
            }];
            sender.layer.cornerRadius = 0.32 * self.view.frame.size.width / 2;
            [self.view layoutIfNeeded];
            }
        }completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3 animations:^{
                if (sender) {
                    [sender mas_remakeConstraints:^(MASConstraintMaker *make){
                        make.size.equalTo(_portraitButton);
                        make.center.equalTo(_portraitButton);
                    }];
                    [self.view layoutIfNeeded];
                }
            }completion:^(BOOL finished) {
                
                [_portraitIcon0 removeFromSuperview];
                [_portraitIcon1 removeFromSuperview];
                [_portraitIcon2 removeFromSuperview];
                [_portraitIcon3 removeFromSuperview];
                [_portraitIcon4 removeFromSuperview];
                _portraitIcon0 = nil;
                _portraitIcon1 = nil;
                _portraitIcon2 = nil;
                _portraitIcon3 = nil;
                _portraitIcon4 = nil;
                _portraitButtonArray = nil;
                
                [UIView animateWithDuration:0.2 animations:^{
                    [self spreadFunctionButtons];
                    [self.view layoutIfNeeded];
                }];
                if (sender) {
                    [UIView animateWithDuration:0.2 animations:^{
                        [_portraitButton setImage:sender.imageView.image forState:UIControlStateNormal];
                        [_sideBarVC.portraitButton setImage:sender.imageView.image forState:UIControlStateNormal];
                    }];
                    // 向服务器上传头像
                    [_currentUser setObject:UIImagePNGRepresentation(sender.imageView.image) forKey:@"icon"];
                    [_currentUser saveInBackground];
                }else if (!sender && [_currentUser objectForKey:@"icon"]) {
                    [_portraitButton setImage:[UIImage imageWithData:[_currentUser objectForKey:@"icon"]] forState:UIControlStateNormal];
                }else if (!sender && ![_currentUser objectForKey:@"icon"]){
                    [_portraitButton setImage:[UIImage imageNamed:@"defaultPortrait"] forState:UIControlStateNormal];
                }
            }];
        }];
}

- (void)portraitButtonUp:(UIButton *)sender{
    #pragma mark 头像事件
    if (_currentUser == nil) {
        LoginViewController *loginVC = [LoginViewController new];
        loginVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        if ([DataHandle SharedData].sideBarHasShown) {
            [self toggleSideBar];
        }
        [self.navigationController pushViewController:loginVC animated:YES];
    }else if(_isChoosingIcon){
        [self didFinishPickingPortraitIcon:nil];
    }else{
        [UIView animateWithDuration:0.3 animations:^{
            [self contractFuctionButtons];
            [self.view layoutIfNeeded];
        }completion:^(BOOL finished) {
            [self spreadPortraitIcons];
        }];
    }
}

- (void)colorPickerCancel{
    _themeColorButton.rotate(-360).animate(0.3);
    [UIView animateWithDuration:0.3 animations:^{
        [_maskView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(_themeColorButton);
            make.size.equalTo(_themeColorButton);
        }];
        _maskView.alpha = 0.0;
        [self.view layoutIfNeeded];
    }];
    
    if (_colorsArray) {
        for (UIButton *color in _colorsArray) {
            [UIView animateWithDuration:0.3 animations:^{
                [color mas_updateConstraints:^(MASConstraintMaker *make){
                    make.center.equalTo(_themeColorButton);
                }];
                color.alpha = 0.0;
                [self.view layoutIfNeeded];
            }completion:^(BOOL finished) {
                [color removeFromSuperview];
            }];
        }
        _colorsArray = nil;
    }
    _colorPickerWasShwon = NO;
}

- (void)setNavigationButtonWithColor:(UIColor *)color{
    _navigationBarButton = [[LBHamburgerButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50) withHamburgerType:LBHamburgerButtonTypeBackButton lineWidth:20 lineHeight:20/6 lineSpacing:2 lineCenter:CGPointMake(25, 25) color: color];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_navigationBarButton];
    [_navigationBarButton addTarget:self action:@selector(toggleSideBar) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"简洁化" style:UIBarButtonItemStylePlain target:self action:@selector(toggleModernMode)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
}

- (void)nightModeSwitch{
    if ([userDefaults boolForKey:@"isNightMode"]) {
        [self dayTime];
    }else{
        [self nightTime];
    }
}

- (void)dayTime{
    [UIView animateWithDuration:0.4 animations:^{
        [_nightModeButton setTitle:@"夜间模式" forState:UIControlStateNormal];
        [_nightModeButton setTitleColor:DayTextColor forState:UIControlStateNormal];
        [_wechatButton setTitleColor:DayTextColor forState:UIControlStateNormal];
        [_weiboButton setTitleColor:DayTextColor forState:UIControlStateNormal];
        [_cleanCacheButton setTitleColor:DayTextColor forState:UIControlStateNormal];
        [_themeColorButton setImage:[AlphaIcons imageOfThemeColorWithFrame:CGRectMake(0, 0, CGRectGetWidth(_themeColorButton.frame), CGRectGetHeight(_themeColorButton.frame))] forState:UIControlStateNormal];
    }];
    [userDefaults setBool:NO forKey:@"isNightMode"];
    [userDefaults synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"day" object:nil];
    
    // 汉堡按钮
    if (_navigationBarButton.hamburgerState == 1) {
        [_navigationBarButton removeFromSuperview];
        _navigationBarButton = nil;
        [self setNavigationButtonWithColor:[UIColor whiteColor]];
        [_navigationBarButton switchState];
    }else{
        [_navigationBarButton removeFromSuperview];
        _navigationBarButton = nil;
        [self setNavigationButtonWithColor:[UIColor whiteColor]];
    }
}

- (void)nightTime{
    [userDefaults setColor:[UIApplication sharedApplication].keyWindow.backgroundColor forKey:@"viewBackgroundColor"];
    [userDefaults setColor:self.navigationController.navigationBar.barTintColor forKey:@"NavigationBarTinColor"];
    [userDefaults synchronize];
    [userDefaults setBool:YES forKey:@"isNightMode"];
    [userDefaults synchronize];
    [UIView animateWithDuration:0.4 animations:^{
        [_nightModeButton setTitle:@"日间模式" forState:UIControlStateNormal];
        [_nightModeButton setTitleColor:NightTextColor forState:UIControlStateNormal];
        [_wechatButton setTitleColor:NightTextColor forState:UIControlStateNormal];
        [_weiboButton setTitleColor:NightTextColor forState:UIControlStateNormal];
        [_cleanCacheButton setTitleColor:NightTextColor forState:UIControlStateNormal];
        [_themeColorButton setImage:[AlphaIcons imageOfThemeColorNightModeWithFrame:CGRectMake(0, 0, CGRectGetWidth(_themeColorButton.frame), CGRectGetHeight(_themeColorButton.frame))] forState:UIControlStateNormal];
    }];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"night" object:nil];
    // 汉堡按钮
    if (_navigationBarButton.hamburgerState == 1) {
        [_navigationBarButton removeFromSuperview];
        _navigationBarButton = nil;
        [self setNavigationButtonWithColor:NightTextColor];
        [_navigationBarButton switchState];
    }else{
        [_navigationBarButton removeFromSuperview];
        _navigationBarButton = nil;
        [self setNavigationButtonWithColor:NightTextColor];
    }
}
- (void)settingsDismiss{
    if (_colorPickerWasShwon) {
        [self colorPickerCancel];
    }
    [UIView animateWithDuration:0.3 animations:^{
        [_nightModeButton mas_remakeConstraints:^(MASConstraintMaker *make){
            make.center.equalTo(_settingsButton);
            make.size.equalTo(_settingsButton);
        }];
        [_themeColorButton mas_remakeConstraints:^(MASConstraintMaker *make){
            make.center.equalTo(_settingsButton);
            make.size.equalTo(_settingsButton);
        }];
        [_cleanCacheButton mas_remakeConstraints:^(MASConstraintMaker *make){
            make.center.equalTo(_settingsButton);
            make.size.equalTo(_settingsButton);
        }];
        _nightModeButton.alpha = 0.1;
        _themeColorButton.alpha = 0.1;
        _cleanCacheButton.alpha = 0.1;
        [self.view layoutIfNeeded];
    }completion:^(BOOL finished) {
        [_nightModeButton removeFromSuperview];
        [_themeColorButton removeFromSuperview];
        [_cleanCacheButton removeFromSuperview];
        [_maskView removeFromSuperview];
        _maskView = nil;
        _nightModeButton = nil;
        _themeColorButton = nil;
        _cleanCacheButton = nil;
    }];
    _settingsWasShown = NO;
}

- (void)shareingDismiss{
    [UIView animateWithDuration:0.3 animations:^{
        [_wechatButton mas_remakeConstraints:^(MASConstraintMaker *make){
            make.center.equalTo(_shareButton);
            make.size.equalTo(_shareButton);
        }];
        [_weiboButton mas_remakeConstraints:^(MASConstraintMaker *make){
            make.center.equalTo(_shareButton);
            make.size.equalTo(_shareButton);
        }];
        _wechatButton.alpha = 0.1;
        _weiboButton.alpha = 0.1;
        
        [self.view layoutIfNeeded];
    }completion:^(BOOL finished) {
        [_wechatButton removeFromSuperview];
        [_weiboButton removeFromSuperview];
        _wechatButton = nil;
        _weiboButton = nil;
    }];
    _shareingWasShwon = NO;
}

- (void)userLoggedInResponse:(NSNotification *)notification{
    self.portraitLabel.text = notification.userInfo[@"username"];
    
    _sideBarVC.nameLabel.text = notification.userInfo[@"username"];
    if (notification.userInfo[@"user"]) {
        _currentUser = notification.userInfo[@"user"];
    }else{
        _currentUser = [AVUser currentUser];
    }
    if ([_currentUser objectForKey:@"icon"]) {
        [self.portraitButton setImage:[UIImage imageWithData:[_currentUser objectForKey:@"icon"]]  forState:UIControlStateNormal];
    }else{
        [self.portraitButton setImage:[UIImage imageNamed:@"defaultPortrait"] forState:UIControlStateNormal];
    }
}

- (void)userLoggedOutResponse{
    self.portraitLabel.text = @"点击登录";
    [self.portraitButton setImage:[UIImage imageNamed:@"defaultPortrait"] forState:UIControlStateNormal];
    [_sideBarVC.portraitButton setImage:[UIImage imageNamed:@"defaultPortrait"] forState:UIControlStateNormal];
    _currentUser = [AVUser currentUser];
}

- (void)edgeAction:(UIScreenEdgePanGestureRecognizer *)sender{
    CGPoint traslation = [sender translationInView:sender.view];
    if (traslation.x > 10 && [DataHandle SharedData].sideBarHasShown == NO) {
        [self toggleSideBar];
    }
}

- (void)toggleSideBar{
    
    if (_isChoosingIcon) {
        [self didFinishPickingPortraitIcon:nil];
    }
    if ([DataHandle SharedData].sideBarHasShown == NO) {
        [DataHandle SharedData].sideBarHasShown = YES;
        [_navigationBarButton switchState];
        [self.view bringSubviewToFront:_sideBarVC.view];
        [UIView animateWithDuration:0.2 animations:^{
            [_sideBarVC.view mas_remakeConstraints:^(MASConstraintMaker *make){
                make.width.mas_equalTo(self.view.frame.size.width * 0.4);
                make.bottom.equalTo(self.view);
                make.left.mas_equalTo(self.view.mas_left);
                make.top.equalTo(self.navigationController.navigationBar.mas_bottom);
            }];
            [self.view layoutIfNeeded];
        }];
        
    }else if ([DataHandle SharedData].sideBarHasShown == YES){
        [DataHandle SharedData].sideBarHasShown = NO;
        [_navigationBarButton switchState];
        [UIView animateWithDuration:0.2 animations:^{
            [_sideBarVC.view mas_remakeConstraints:^(MASConstraintMaker *make){
                make.width.mas_equalTo(self.view.frame.size.width * 0.4);
                make.bottom.equalTo(self.view);
                make.right.mas_equalTo(self.view.mas_left);
                make.top.equalTo(self.navigationController.navigationBar.mas_bottom);
            }];
            [self.view layoutIfNeeded];
        }];
    }
}

- (void)toggleModernMode{
    ProfileViewControllerModernized *PVCM = [ProfileViewControllerModernized new];
    PVCM.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:PVCM] animated:YES completion:nil];
}

- (void)themeColorUpdate:(NSNotification *)notification{
    [userDefaults setColor:notification.userInfo[@"dark"] forKey:@"dark"];
    [userDefaults setColor:notification.userInfo[@"light"] forKey:@"light"];
    [userDefaults setColor:notification.userInfo[@"normal"] forKey:@"normal"];
    [userDefaults setColor:notification.userInfo[@"threashold"] forKey:@"threashold"];
    
    self.tabBarController.tabBar.barTintColor = notification.userInfo[@"dark"];
    self.tabBarController.tabBar.tintColor = notification.userInfo[@"light"];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    if (_settingsWasShown) {
        [self settingsDismiss];
    }
    if (_shareingWasShwon) {
        [self shareingDismiss];
    }
    if ([DataHandle SharedData].sideBarHasShown) {
        [self toggleSideBar];
    }
}

- (void)cleanCacheAction:(UIButton *)sender{
    _animateTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(cleanCacheAnimation) userInfo:nil repeats:YES];
    [self cleanCacheAnimation];
}

- (void)cleanCacheAnimation{
    if ([[[_cleanCacheButton.titleLabel.text substringWithRange:NSMakeRange(6, 4)] stringByReplacingOccurrencesOfString:@"M" withString:@"" options:NSBackwardsSearch range:NSMakeRange(3, 1)] floatValue] > 0.0) {
        float animationSimulator = [[[_cleanCacheButton.titleLabel.text substringWithRange:NSMakeRange(6, 4)] stringByReplacingOccurrencesOfString:@"M" withString:@"" options:NSBackwardsSearch range:NSMakeRange(3, 1)] floatValue] - ((arc4random() % 2) + 0.2);
        if (animationSimulator < 0) {
            animationSimulator = 0;
        }
        [_cleanCacheButton setTitle:[NSString stringWithFormat:@"清理缓存: %.1fM",animationSimulator] forState:UIControlStateNormal];
    }else{
        [[DataHandle SharedData] clearCache];
        [_animateTimer invalidate];
        _animateTimer = nil;
        [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(afterMath:) userInfo:nil repeats:YES];
        [_cleanCacheButton setBackgroundImage:[AlphaIcons imageOfBorderWithIndicatorWithFrame:_cleanCacheButton.bounds fraction:0 / 195.0 scale:is_iPhone4 ? 0.97 : (is_iPhone5? 0.97:1.15)] forState:UIControlStateNormal];
        [_cleanCacheButton setTitle:@"清理缓存: 0.0M" forState:UIControlStateNormal];
    }
}

- (void)afterMath:(NSTimer *)sender{
    if ([DataHandle SharedData].cacheCount == 0.0) {
        [_cleanCacheButton setBackgroundImage:[AlphaIcons imageOfBorderWithIndicatorWithFrame:_cleanCacheButton.bounds fraction:[DataHandle SharedData].cacheCount / 195.0 scale:is_iPhone4 ? 0.97 : (is_iPhone5? 0.97:1.15)] forState:UIControlStateNormal];
        [_cleanCacheButton setTitle:[NSString stringWithFormat:@"清理缓存: %.1fM",[DataHandle SharedData].cacheCount] forState:UIControlStateNormal];
        [sender invalidate];
    }
}

- (void)incomplete{
    [self popAlertWithText:@"该功能暂未实现"];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)popAlertWithText:(NSString *)text{
    
    if (_alertLock == NO) {
        _alertLock = YES;
        UILabel * alertView = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.view.frame) - (self.view.frame.size.width * 0.8) /2, [UIScreen mainScreen].bounds.origin.y-80, self.view.frame.size.width * 0.8, 80)];
        alertView.textAlignment = NSTextAlignmentCenter;
        alertView.numberOfLines = 0;
        alertView.text = text;
        alertView.backgroundColor = [UIColor colorWithRed:0.8303 green:0.5408 blue:0.1462 alpha:0.6];
        alertView.font = [UIFont fontWithName:@"Helvetica" size:20];
        alertView.textColor = [UIColor whiteColor];
        [self.view addSubview:alertView];
        
        [UIView animateWithDuration:0.25 animations:^{
            
            alertView.frame = CGRectMake(CGRectGetMidX(self.view.frame) - (self.view.frame.size.width * 0.8) /2, 0, self.view.frame.size.width * 0.8, 80);
        }completion:^(BOOL finished) {
            [self performSelector:@selector(dismissAlert:) withObject:alertView afterDelay:2.0];
        }];
    }
}

- (void)dismissAlert:(UILabel *)alert{
    _alertLock = NO;
    [UIView animateWithDuration:0.25 animations:^{
        alert.frame = CGRectMake(CGRectGetMidX(self.view.frame) - (self.view.frame.size.width * 0.8) /2, [UIScreen mainScreen].bounds.origin.y-80, self.view.frame.size.width * 0.8, 80);
    }completion:^(BOOL finished) {
        
        [alert removeFromSuperview];
    }];
}
@end
