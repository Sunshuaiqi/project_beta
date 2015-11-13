//
//  PictureBrowsingViewController.m
//  ProjectAlpha
//
//  Created by lanou3g on 15/10/25.
//  Copyright © 2015年 com.sunshuaiqi. All rights reserved.
//

#import "PictureBrowsingViewController.h"
#import "ProjectAlpha-Swift.h"
@interface PictureBrowsingViewController ()<UIScrollViewDelegate>

@property (nonatomic,strong) UILabel * titleLabel; // 介绍文字

@property (nonatomic,strong) UIScrollView * scrollView; // 滚动视图

@property (nonatomic,strong) UIImageView * imgView; // 图片视图

@end

@implementation PictureBrowsingViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    

    self.navigationItem.title = [NSString stringWithFormat:@"(1/%ld)",(unsigned long)self.imgIdsArray.count];
    
    
}
- (void)viewDidLoad {
    [super viewDidLoad];

    //self.view.backgroundColor = [UIColor whiteColor];
    // 更改navigationController背景颜色
    if ([userDefaults boolForKey:@"isNightMode"]) {
        
        self.navigationController.navigationBar.barTintColor = NightBackgroundColor;
        self.view.backgroundColor = NightBackgroundColor;
        
    }else {
        
        if ([userDefaults colorForKey:@"dark"]) {
            
            self.navigationController.navigationBar.barTintColor = [userDefaults colorForKey:@"dark"];
            
        }
        
         if ([userDefaults colorForKey:@"light"]) {
             
            self.view.backgroundColor = [userDefaults colorForKey:@"light"];
         }
    }
    [self addSubViews];
    
    

}


// 添加视图
- (void)addSubViews
{

    // 返回按钮
    UIBarButtonItem * backBI = [[UIBarButtonItem alloc] initWithImage:[AlphaIcons imageOfBackArrowWithFrame:CGRectMake(0, 0, 30, 30
                                                                                                                       )] style:UIBarButtonItemStylePlain target:self action:@selector(didClickBackBI)];
    backBI.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = backBI;
   
    
    // 滚动视图
    self.scrollView = [UIScrollView new];
    [self.view addSubview:_scrollView];
  
    [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.top.equalTo(self.view.mas_top).offset(64);
        make.left.and.right.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_bottom).offset(-250/667.0*ScreenHeight);
        
    }];
    _scrollView.contentSize = CGSizeMake(self.view.frame.size.width * self.imgIdsArray.count, self.scrollView.frame.size.height);
    
    // 分页显示
    _scrollView.pagingEnabled = YES;
    
    // 允许滚动
    _scrollView.scrollEnabled = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    
    // 不显示scrollView垂直方向的滚动条
    _scrollView.showsVerticalScrollIndicator = NO;
    
    // 缩放比例
//    _scrollView.maximumZoomScale = 2.0;
//    _scrollView.minimumZoomScale = 0.5;
    
    _scrollView.delegate = self;
    
  
    
    // 图片视图
    
    for (int i = 0; i < self.imgIdsArray.count; i++) {
        
        self.imgView = [UIImageView new];
       
         [_imgView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://img1.cutt.com/img/%@/",_imgIdsArray[i]]] placeholderImage:[UIImage imageNamed:@"43.jpg"]];
        
       [self.scrollView addSubview:_imgView];
        
       [_imgView mas_makeConstraints:^(MASConstraintMaker *make) {
          
           make.left.mas_equalTo(self.view.frame.size.width * i);
           make.width.mas_equalTo(self.view.frame.size.width);
           make.centerY.mas_equalTo(self.scrollView.mas_centerY);
           make.height.mas_equalTo(self.scrollView).offset(-10);
           
       }];
    }
    
    // 标题label
    self.titleLabel = [UILabel new];
    self.titleLabel.textColor = [UIColor darkGrayColor];
    self.titleLabel.font = [UIFont systemFontOfSize:20];
    self.titleLabel.text = self.intro;
    self.titleLabel.numberOfLines = 0;
    [self.view addSubview:_titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.top.equalTo(self.scrollView.mas_bottom).offset(30);
        make.left.and.right.equalTo(self.view);
        make.height.mas_equalTo(80);
    }];
    

}


// 返回事件
- (void)didClickBackBI
{

    [self dismissViewControllerAnimated:YES completion:nil];
    
}


#pragma mark -- scrollViewDelegate 代理方法
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // 根据偏移量得到当前页面
    NSInteger  currentPage = self.scrollView.contentOffset.x / self.scrollView.frame.size.width;
    
    // 显示标题
    self.navigationItem.title = [NSString stringWithFormat:@"(%ld/%ld)",currentPage + 1,self.imgIdsArray.count];


}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
