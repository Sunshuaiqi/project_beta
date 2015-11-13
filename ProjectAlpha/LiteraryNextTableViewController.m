//
//  LiteraryNextTableViewController.m
//  ProjectAlpha
//
//  Created by lanou3g on 15/10/23.
//  Copyright © 2015年 com.sunshuaiqi. All rights reserved.
//

#import "LiteraryNextTableViewController.h"
#import "LiteraryNextModel.h"
#import "LiteraryNextTableViewCell.h"
#import "LiteraryDetailViewController.h"
#import "DataHandle.h"
#import <AVOSCloud.h>
#import "ProjectAlpha-Swift.h"
@interface LiteraryNextTableViewController ()
@property (nonatomic,strong) NSMutableArray * modelArray;

@property (nonatomic,strong)  UIImageView * headerImageView;
@end

@implementation LiteraryNextTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addSubviews];
   // self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // 更改navigationController背景颜色
    if ([userDefaults boolForKey:@"isNightMode"]) {
        
       self.navigationController.navigationBar.barTintColor = NightBackgroundColor;
       self.tableView.backgroundColor = NightBackgroundColor;
        
    }else {
        
        if ([userDefaults colorForKey:@"dark"]) {
            
            self.navigationController.navigationBar.barTintColor = [userDefaults colorForKey:@"dark"];

        }
        
        
        if ([userDefaults colorForKey:@"light"]) {
            self.tableView.backgroundColor = [userDefaults colorForKey:@"light"];
        }
        
    }
    
    
    [self parseData];
}


#pragma mark --  添加子控件
- (void)addSubviews
{

    self.navigationItem.title = self.titleName;
    
    self.headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0 , 180)];
    [_headerImageView sd_setImageWithURL:[NSURL URLWithString:self.imgUrl] placeholderImage:[UIImage imageNamed:@"43.jpg"]];
    self.tableView.tableHeaderView = _headerImageView;
    
    UIBarButtonItem * backBI = [[UIBarButtonItem alloc] initWithImage:[AlphaIcons imageOfBackArrowWithFrame:CGRectMake(0, 0, 30, 30)] style:UIBarButtonItemStylePlain target:self action:@selector(didBackBI)];
    backBI.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = backBI;

}


// 返回按钮
- (void)didBackBI
{
    [self dismissViewControllerAnimated:YES completion:nil];

}

#pragma mark -- 解析数据
- (void)parseData
{

    NSURL * url = [NSURL URLWithString:kLiteraryNextUrl(self.modelID)];
    
    NSURLRequest * request = [[NSURLRequest alloc] initWithURL:url];
    __weak LiteraryNextTableViewController * weakSelf = self;
    NSURLSessionDataTask * task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (data != nil) {
            
            NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
         
            NSArray * dataArray = dict[@"data"];
            
            self.modelArray = [NSMutableArray array];
              
            for (int i = 0; i < dataArray.count; i++) {
                
                NSDictionary * dataDict = dataArray[i][@"data"];
                
                for (NSString * key in dataDict) {
                    if ([key isEqualToString:@"pin"]) {
                        // 如果pin 中的value值 是字典形式 ，则通过kvc将pin中的值赋给model对象，反之，直接将data中的值赋给model对象
                        if ([dataDict[@"pin"] isKindOfClass:[dataDict class]]) {
                            
                            LiteraryNextModel * model = [LiteraryNextModel new];
                            
                            [model setValuesForKeysWithDictionary:dataDict[@"pin"]];
                            
                            [weakSelf.modelArray addObject:model];
                            
                        }else{
                            LiteraryNextModel * model = [LiteraryNextModel new];
                            
                            [model setValuesForKeysWithDictionary:dataDict];
                            
                            [weakSelf.modelArray addObject:model];
                            
                        }
                        
                    }
                    
                }

            }
            
        }
        
         dispatch_async(dispatch_get_main_queue(), ^{
             
             // 刷新数据
             [weakSelf.tableView reloadData];
         });
       

        
    }];
    
       // 开始执行
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
    LiteraryNextTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier"];
    if (cell == nil) {
        
        cell = [[LiteraryNextTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reuseIdentifier"];
    }
    
    
    LiteraryNextModel * model = _modelArray[indexPath.row];
    cell.titleLabel.text = model.text;
    [cell.imgview sd_setImageWithURL:[NSURL URLWithString:model.image_url] placeholderImage:_headerImageView.image];
    cell.introLabel.text = model.short_content;
    cell.dataLabel.text = [model.created_at substringToIndex:10];
    
    
    if ([userDefaults boolForKey:@"isNightMode"]) {
        // 夜间模式
        cell.titleLabel.textColor = NightTextColor;
    }else {
        
        // 主题颜色或者白天模式
        cell.titleLabel.textColor = [UIColor blackColor];
        
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    return  150;

}
#pragma mark --- 进入详情页
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    LiteraryDetailViewController * detailVC = [LiteraryDetailViewController new];

    LiteraryNextModel * model = _modelArray[indexPath.row];
    
    // 将id传到下一个页面中
    detailVC.ID = model.ID;
    detailVC.title = model.text;
    detailVC.titleStr = model.text;
    detailVC.imgUrl = model.image_url;
    
    [self addHistoryBrowseInfoWithIndexPath:indexPath];

    [self showViewController:detailVC sender:nil];
   

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
    
    LiteraryNextModel * model = _modelArray[indexPath.row];
    
    // 如果登录了就将其浏览记录添加到数据库中，否则不添加
    if ([AVUser currentUser]) {
        
        [[DataHandle SharedData] insertDataWithID:[NSString stringWithFormat:@"%ld",model.ID] title:model.text imgUrl:model.image_url paragraph:nil time:time];
    }
    
}


@end
