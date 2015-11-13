//
//  DataHandle.h
//  ProjectAlpha
//
//  Created by lanou3g on 10/30/15.
//  Copyright © 2015 com.sunshuaiqi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDatabase.h>
#import <FMDatabaseQueue.h>
@interface DataHandle : NSObject
@property(nonatomic, assign) BOOL sideBarHasShown;

+ (instancetype)SharedData;

@property (nonatomic, assign) float cacheCount;
#pragma mark -- 历史记录
@property(nonatomic,strong)FMDatabase * dataBase;

// 创建数据库
- (void)createDB;

// 添加数据到数据库
- (void)insertDataWithID:(NSString *)ID title:(NSString *)title imgUrl:(NSString *)imgUrl paragraph:(NSString *)paragraph time:(NSString *)time;

// 查询数据库
- (NSMutableArray *)qureyData;

// 根据id删除元素
- (void)deleteDataWithID:(NSString *)ID;


// 删除数据库中所有的元素
- (void)deleteAllData;

//遍历文件夹获得文件夹大小，返回多少M
- (float ) folderSizeAtPath:(NSString*) folderPath;

// 清除缓存
- (void)clearCache;

@end
