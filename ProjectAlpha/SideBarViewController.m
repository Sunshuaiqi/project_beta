//
//  ViewController.m
//  sideBar
//
//  Created by lanou3g on 10/27/15.
//  Copyright © 2015 com.sunshuaiqi. All rights reserved.
//

#import "SideBarViewController.h"
#import <LeanCloudFeedback/LeanCloudFeedback.h>
#import "ProjectAlpha-Swift.h"
#import "DataHandle.h"
#import "About.h"
#import "ProfileViewController.h"

@interface SideBarViewController ()<UITableViewDataSource,UITableViewDelegate, UIGestureRecognizerDelegate>

@property(nonatomic, strong) UIGestureRecognizer *gestureReconizer;
@end

@implementation SideBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _gestureReconizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    [self.view addGestureRecognizer:_gestureReconizer];
    _gestureReconizer.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nightMode) name:@"night" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dayMode) name:@"day" object:nil];
    _portraitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    [self.view addSubview:_portraitButton];
    [self.view addSubview:_tableView];
    [_portraitButton addTarget:self action:@selector(didClickPortraitButton) forControlEvents:UIControlEventTouchUpInside];
    
    [_portraitButton mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.equalTo(self.view).offset(self.view.frame.size.height * 0.05);
        make.centerX.equalTo(_tableView);
        make.width.and.height.mas_equalTo(self.view.frame.size.width*0.5);
    }];
    
    _nameLabel = [UILabel new];
    [self.view addSubview:_nameLabel];
    _nameLabel.textColor = [UIColor whiteColor];
    _nameLabel.textAlignment = NSTextAlignmentCenter;
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.equalTo(_portraitButton.mas_bottom);
        make.width.equalTo(self.view);
        make.centerX.equalTo(_tableView);
        make.height.mas_equalTo(30 / 667.0 * ScreenHeight);
    }];
    
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make){
        make.width.mas_equalTo(self.view);
        make.bottom.and.right.equalTo(self.view);
        make.top.equalTo(_nameLabel.mas_bottom);
    }];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.scrollEnabled = NO;
    _tableView.backgroundColor = [UIColor clearColor];
    
    #pragma mark 设置侧边栏背景颜色
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isNightMode"]) {
        self.view.backgroundColor = [UIColor colorWithRed:0.1639 green:0.1559 blue:0.1297 alpha:1.0];
    }else{
        self.view.backgroundColor = [UIColor colorWithRed:0.1934 green:0.2321 blue:0.3038 alpha:1.0];
    }
    _tableView.dataSource = self;
    _tableView.delegate = self;
}

-(void)viewWillAppear:(BOOL)animated{
    
    [_portraitButton mas_remakeConstraints:^(MASConstraintMaker *make){
        make.top.equalTo(self.view).offset(self.view.frame.size.height * 0.05);
        make.centerX.equalTo(_tableView);
        make.width.and.height.mas_equalTo(self.view.frame.size.width*0.5);
    }];
}
- (void)didClickPortraitButton{
    
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  4;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell=[tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier"];
    if (cell==nil) {
        cell=[[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:@"reuseIdentifier"];
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"退出登录";
            break;
        case 1:
            cell.textLabel.text = @"引 导 页";
            break;
        case 3:
            cell.textLabel.text = @"关于";
        default:
            break;
    }
    cell.textLabel.textColor = [UIColor whiteColor];
    return cell;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    _portraitButton.layer.cornerRadius = _portraitButton.frame.size.width /2;
    _portraitButton.clipsToBounds = YES;
    _portraitButton.layer.borderWidth = 2;
    _portraitButton.layer.borderColor = [UIColor whiteColor].CGColor;
}

- (void)panAction:(UIPanGestureRecognizer *)sender{
    
    CGPoint point = [sender translationInView:sender.view];
    
    if (CGRectGetMinX(sender.view.frame) >= 0 && [DataHandle SharedData].sideBarHasShown) { // 防止左边栏脱离屏幕边缘
        sender.view.frame = CGRectMake(0, CGRectGetMinY(sender.view.frame), CGRectGetWidth(sender.view.frame), CGRectGetHeight(sender.view.frame));
    }
    
    if (point.x < -5 && [DataHandle SharedData].sideBarHasShown) { // 左边栏收起
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"toggleSideBar" object:nil];
        return;
    }
    [sender setTranslation:CGPointZero inView:self.view];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:
            [AVUser logOut];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"userLogOut" object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"toggleSideBar" object:nil];
            _nameLabel.text = @"";
            break;
        case 1:
            [userDefaults setBool:NO forKey:@"isFirstLaunch"];
            [userDefaults synchronize];
            
            [_delegate introPage];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"toggleSideBar" object:nil];
            break;
        case 3:
            [self.navigationController pushViewController:[About new] animated:YES];
            break;
            
        default:
            break;
    }
}

- (void)dayMode{
    [UIView animateWithDuration:0.3 animations:^{
        self.view.backgroundColor = [UIColor colorWithRed:0.1934 green:0.2321 blue:0.3038 alpha:1.0];
    }];
    
}

- (void)nightMode{
    [UIView animateWithDuration:0.3 animations:^{
        
        self.view.backgroundColor = [UIColor colorWithRed:0.1639 green:0.1559 blue:0.1297 alpha:1.0];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"night" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"day" object:nil];
}

@end
