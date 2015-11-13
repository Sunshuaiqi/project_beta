//
//  FavoriteHandle.h
//  ProjectAlpha
//
//  Created by lanou3g on 15/10/29.
//  Copyright © 2015年 com.sunshuaiqi. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <FMDatabase.h>
#import <FMDatabaseQueue.h>

@interface FavoriteHandle : NSObject

// 数据库
@property (nonatomic,strong) FMDatabase * dataBase;//创建数据库管理对象

@property (nonatomic,assign) BOOL isViaClickFavorite; // 是否点击收藏按钮

#pragma mark -- 创建单例
+ (FavoriteHandle *)sharedHandle;


#pragma mark -- 收藏

// 创建数据库
- (void)createDB;

// 添加数据到数据库
- (void)insertDataWithID:(NSString *)ID title:(NSString *)title imgUrl:(NSString *)imgUrl paragraph:(NSString *)paragraph;

// 查询数据库
- (NSMutableArray *)qureyData;

// 根据id删除元素
- (void)deleteDataWithID:(NSString *)ID;

// 删除数据库中所有的元素
- (void)deleteAllData;

@end
