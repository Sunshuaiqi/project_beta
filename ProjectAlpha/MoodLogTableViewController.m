//
//  MoodLogTableViewController.m
//  ProjectAlpha
//
//  Created by lanou3g on 15/10/27.
//  Copyright © 2015年 com.sunshuaiqi. All rights reserved.
//

#import "MoodLogTableViewController.h"
#import "MoodLogTableViewCell.h"
#import "MoodLogModel.h"

#import "TFHpple.h"
#import "MoodLogDetailViewController.h"
#import "DataHandle.h"
#import <AVOSCloud.h>
#import "ProjectAlpha-Swift.h"
#define kMoonLogUrl @"http://www.wumii.com/app/mobile/auto/site/items?obSiteId=2uRkHJ3P&ord=TIME_DESC"

@interface MoodLogTableViewController ()

@property (nonatomic,strong) NSMutableArray * modelArray;

@property (nonatomic,strong) NSMutableArray * imgUrlArray; // 存放图片网址的数组
@property (nonatomic,strong) NSMutableArray * paragraphArray; // 存放所有文章内容的数组

@end

@implementation MoodLogTableViewController

// 懒加载
- (NSMutableArray *)modelArray
{
    if (!_modelArray) {
        
        _modelArray = [NSMutableArray array];
    }
    
    return _modelArray;
}

- (NSMutableArray *)paragraphArray
{

    if (!_paragraphArray) {
        
        _paragraphArray = [NSMutableArray array];
    }

    return _paragraphArray;
}

- (NSMutableArray *)imgUrlArray
{
    if (!_imgUrlArray) {
        
        _imgUrlArray = [NSMutableArray array];
    }

    return _imgUrlArray;
}


// 视图出现
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 55, 0);
    self.tableView.backgroundColor = [UIColor clearColor];
    [self parseData];
    // 颜色更改通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeColorUpdate:) name:@"themeColorUpdate" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nightMode:) name:@"night" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dayMode:) name:@"day" object:nil];
    //给偏移量添加观察者
    [self.tableView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    
    // 上拉加载，下拉刷新
    [self UpLoadingAndDownRefresh];
    
}

-(void)dealloc
{
    // 颜色更改通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"themeColorUpdate" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"night" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"day" object:nil];
    // 移除观察者
    [self.tableView removeObserver:self forKeyPath:@"contentOffset"];

}

// 夜间模式
- (void)nightMode:(NSNotification *)notification
{
    
    self.tableView.backgroundColor = NightBackgroundColor;
    
    [self.tableView reloadData];
}

// 日间模式
- (void)dayMode:(NSNotification *)notification
{
    
    if ([userDefaults colorForKey:@"light"]) {
        
        self.tableView.backgroundColor = [userDefaults colorForKey:@"light"];
        
    }else {
        
        self.tableView.backgroundColor = [UIColor whiteColor];
        
    }
    
    [self.tableView reloadData];
}

// 颜色改变
- (void)themeColorUpdate:(NSNotification *)notification
{
    
    self.tableView.backgroundColor = notification.userInfo[@"light"];
    
    
    [self.tableView reloadData];
    
}


#pragma mark --- ---------  上拉加载，下拉刷新  ----------------
- (void)UpLoadingAndDownRefresh
{
    
    // 下拉刷新
    __weak MoodLogTableViewController * weakSelf = self;
    
    // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        if (weakSelf.modelArray.count == 0) {
            [weakSelf parseData];
        }
        // 刷新表格
        [weakSelf.tableView reloadData];
        
        
        // 拿到当前的下拉刷新控件，结束刷新状态
        [weakSelf.tableView.header endRefreshing];
        
        
    }];
    
    // 设置自动切换透明度(在导航栏下面自动隐藏)
    weakSelf.tableView.header.automaticallyChangeAlpha = YES;
    
}




// 解析数据
- (void)parseData
{
    NSURL * url = [NSURL URLWithString:kMoonLogUrl];
    NSURLRequest * request = [[NSURLRequest alloc] initWithURL:url];
    __weak MoodLogTableViewController * weakSelf = self;
    NSURLSessionDataTask * task = [[NSURLSession sharedSession]  dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (data != nil) {
            
            NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            
            NSDictionary * readerModuleDic = dict[@"readerModule"];
            NSArray * itemInfosArray = readerModuleDic[@"itemInfos"];
            
            for (NSDictionary * dic in itemInfosArray) {
                
                MoodLogModel * model = [MoodLogModel new];
                [model setValuesForKeysWithDictionary:dic[@"item"]];
                 //把模型添加到数组中
                [weakSelf.modelArray addObject:model];
                
                
                // 得到HTML的网址
                NSData * htmlData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:model.name]];
                // 解析html 数据
                TFHpple * parser = [[TFHpple alloc] initWithHTMLData:htmlData];
                NSArray * array = [parser searchWithXPathQuery:@"//div"];
                
                for (TFHppleElement * element in array) {
                    
                    if ([element.attributes[@"class"] isEqualToString:@"content clearfix"]) {
                        
                        // 得到图片网址
                        NSArray * array1 = [element searchWithXPathQuery:@"//img"];
                        
                        // 得到数组中的首元素
                        if (array1.count != 0) {
                            TFHppleElement * element1 = array1[0];
                            
                            [weakSelf.imgUrlArray addObject:element1.attributes[@"src"]];
                            
                            }
                            // 得到段落
                            
                            [weakSelf.paragraphArray addObject:element.content];
                        
    
        
                    }
                    
                }

               
                
            }
            
        }
       
        // 主线程
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [weakSelf.tableView reloadData];
            
        });
        
    }];
    
    [task resume];
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return _modelArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MoodLogTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier"];
    if (cell == nil) {
        cell = [[MoodLogTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reuseIdentifier"];
    }
    MoodLogModel * model = [MoodLogModel new];
    if (_modelArray.count!=0) {
        
        model = _modelArray[indexPath.row];

    }
    
    // 标题
    cell.titleLabel.text = model.metadata;
    
    [cell.imgView sd_setImageWithURL:[NSURL URLWithString:self.imgUrlArray[indexPath.row]]];
    
    //cell 上标题颜色
    if ([userDefaults boolForKey:@"isNightMode"]) {
        // 夜间模式
        cell.titleLabel.backgroundColor = NightBackgroundColor;
       
    }else{
        
        // 跟随主题颜色
        if ([userDefaults colorForKey:@"dark"]) {
            cell.titleLabel.backgroundColor = [userDefaults colorForKey:@"dark"];
           
        } else {
        
            // 日间模式
            cell.titleLabel.backgroundColor = [UIColor colorWithRed:0.329 green:0.765 blue:0.945 alpha:0.928];
        
        }
    }
    
        cell.titleLabel.alpha = 0.7;
  
 
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return  250;
    
}


#pragma mark -- 进入详情页
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    MoodLogDetailViewController * detailVC = [[MoodLogDetailViewController alloc] init];
    
    UINavigationController * NC = [[UINavigationController alloc] initWithRootViewController:detailVC];
    
    // 改变navigationbar 的背景色
    if ([userDefaults boolForKey:@"isNightMode"]) {
        
        NC.navigationBar.tintColor = [UIColor blackColor];
    }else{
        if ([userDefaults colorForKey:@"dark"]) {
            NC.navigationBar.barTintColor = [userDefaults colorForKey:@"dark"];

        }
    }
    
    
    detailVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    MoodLogModel * model = _modelArray[indexPath.row];
    
    detailVC.title = model.metadata;
    detailVC.content = self.paragraphArray[indexPath.row];
    detailVC.imgUrl = self.imgUrlArray[indexPath.row];
    detailVC.ID = model.ID;
    
     [self addHistoryBrowseInfoWithIndexPath:indexPath];
    
    [self presentViewController:NC animated:YES completion:nil];

}




#pragma mark --  将浏览历史添加到数据库中--
- (void)addHistoryBrowseInfoWithIndexPath:(NSIndexPath *)indexPath
{
    // 得到当前日期
    NSDate * nowDate = [NSDate date];
    // 对日期进行格式化yyyy-MM-dd hh:mm:ss
    NSDateFormatter * format = [NSDateFormatter new];
    [format setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    // 将日期转化为对应的字符串
    NSString * time = [format stringFromDate:nowDate];
    print(@"%@",time);
    
    MoodLogModel * model = _modelArray[indexPath.row];
    
    // 如果登录了就将其浏览记录添加到数据库中，否则不添加
    if ([AVUser currentUser]) {
        
        [[DataHandle SharedData] insertDataWithID:model.ID title:model.metadata imgUrl:self.imgUrlArray[indexPath.row] paragraph:self.paragraphArray[indexPath.row] time:time];
    }
    
}




#pragma mark -- 上滑时tabbar消失，下拉是tabbar出现
//实现观察者方法
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    
    CGPoint newContOffset = [change[NSKeyValueChangeNewKey] CGPointValue];
    
    CGPoint oldContOffset= [change[NSKeyValueChangeOldKey] CGPointValue];
    
    CGFloat dy = newContOffset.y - oldContOffset.y;
    // 上滑手势
    if (dy > 0) {
        // tabbar 在屏幕内显示
        if (self.tabBarController.tabBar.frame.origin.y < ScreenHeight ) {
            
            self.tabBarController.tabBar.frame = CGRectMake(0, CGRectGetMinY(self.tabBarController.tabBar.frame)+dy, ScreenWidth, 49);
            
        }else{ // tabbar 不在屏幕中（将其放在屏幕的最下方）
            
            self.tabBarController.tabBar.frame = CGRectMake(0, ScreenHeight, ScreenWidth, 49);
        }
        
        
        // 下拉手势
    }else if(dy <= 0){
        // 不在原有位置
        if (self.tabBarController.tabBar.frame.origin.y > ScreenHeight-49) {
            
            self.tabBarController.tabBar.frame = CGRectMake(0, CGRectGetMinY(self.tabBarController.tabBar.frame)+dy, ScreenWidth, 49);
            
        }else{
            // 在原有位置
            self.tabBarController.tabBar.frame = CGRectMake(0, ScreenHeight - 49, ScreenWidth, 49);
            
        }
        
    }
    
    // 防止回弹时，tabbar消失
    if (oldContOffset.y < 200) {
        
        self.tabBarController.tabBar.frame = CGRectMake(0,ScreenHeight- 49, ScreenWidth, 49);
    }
    
    
}




@end
