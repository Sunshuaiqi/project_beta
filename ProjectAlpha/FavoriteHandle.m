//
//  FavoriteHandle.m
//  ProjectAlpha
//
//  Created by lanou3g on 15/10/29.
//  Copyright © 2015年 com.sunshuaiqi. All rights reserved.
//

#import "FavoriteHandle.h"

#import "FavoriteModel.h"
#import <AVOSCloud.h>

@interface FavoriteHandle ()
@property (nonatomic,strong) NSMutableArray * array; // 存放查询结果的数组
@end

@implementation FavoriteHandle

#pragma mark -- 创建单例
static FavoriteHandle * handle = nil;

+ (FavoriteHandle *)sharedHandle
{

    static dispatch_once_t predicated;
    dispatch_once(&predicated, ^{
       
        handle = [[FavoriteHandle alloc] init];
        
    });

    return handle;
}



// 千万不要使用懒加载（否则会出现重复创建的情况）
//- (NSMutableArray *)array
//{
//
//    if (_array == nil) {
//        
//        _array = [NSMutableArray array];
//    }
//
//    return _array;
//}

#pragma mark -- 创建数据库
- (void)createDB
{

    // 找到document的路径
    NSString * documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    
    // 数据库存放地址
    NSString * filePath = [documentPath stringByAppendingPathComponent:@"Favorite.db"];
    

    // 创建数据库
    self.dataBase = [FMDatabase databaseWithPath:filePath];
    
     print(@"数据库所在路径：%@",filePath);
    
    // 打开数据库的情况
    if ([self.dataBase open]) {
        
        print(@"数据库创建成功");
        
        // 创建表 (列名，类型)
        // （1）存放文章的表  (根据当前用户名创建表名)
        NSString * tableName = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (ID text PRIMARY KEY , title TEXT, imageUrl TEXT,paragraph TEXT);",[AVUser currentUser].username];
        
         BOOL result =  [self.dataBase executeUpdate:tableName];
        
        if (result) {
            print(@"成功建表（文章）");
        } else {
        
            print(@"建表失败");
        }
    }

}


#pragma mark -- 向表中添加数据
- (void)insertDataWithID:(NSString *)ID title:(NSString *)title imgUrl:(NSString *)imgUrl paragraph:(NSString *)paragraph
{

    [self createDB];
    
    if ([self.dataBase open]) {
        
        NSMutableArray * array = [self qureyData];
        
        for (FavoriteModel * model in array) {
            
            if ([model.ID isEqualToString:ID]) {
                print(@"已经收藏过了");
                
                [self.dataBase close];
                
                return;
            }
        }
        
        // 数据库中没有收藏过，就收藏
        // 添加数据
        NSString * insertTableName = [NSString stringWithFormat:@"insert into %@ (ID,title,imageUrl,paragraph) values (?,?,?,?)",[AVUser currentUser].username];
        
        [self.dataBase executeUpdate:insertTableName, ID, title,imgUrl,paragraph];
        
        print(@"收藏成功");
        
    }
    
    // 关闭数据库
    [self.dataBase close];

}


#pragma mark -- 查询数据库
- (NSMutableArray *)qureyData
{

    [self createDB];
    if ([self.dataBase open]) {
        self.array = [NSMutableArray array];
        // 执行查询语句
        FMResultSet * resultSet = [self.dataBase executeQuery:[NSString stringWithFormat:@"select * from %@",[AVUser currentUser].username]];
        
        // 遍历结果
        while ([resultSet next]) {
             FavoriteModel * model = [FavoriteModel new];
            NSString * ID = [resultSet stringForColumn:@"ID"];
            NSString * title = [resultSet stringForColumn:@"title"];
            NSString * imgUrl = [resultSet stringForColumn:@"imageUrl"];
            NSString * paragraph = [resultSet stringForColumn:@"paragraph"];

            
            // 赋值给model
           
            model.ID = ID;
            model.titleStr = title;
            model.imgUrl = imgUrl;
            model.paragraph = paragraph;
            [self.array addObject:model];
        }
        
        
    }
    
    
    return _array;
}



#pragma mark --- 根据id删除数据库中的元素
- (void)deleteDataWithID:(NSString *)ID
{   

    [self createDB];
    if ([self.dataBase open]) {
    
        NSString * deleteInfoTable = [NSString stringWithFormat:@"delete from %@ where ID = ?",[AVUser currentUser].username];
        
        BOOL isSuccess = [_dataBase executeUpdate:deleteInfoTable,ID];
        
        if (isSuccess) {
            
            print(@"删除一条新的收藏记录成功");
            
        } else {
            
            print(@"删除一条新的收藏记录失败");
            
        }
        
        
    }

}

#pragma mark -- 删除数据库中所有的元素

- (void)deleteAllData
{

    [self createDB];
    if ([self.dataBase open]) {
        
        NSString * sql = [NSString stringWithFormat:@"delete from %@",[AVUser currentUser].username];
        
        [self.dataBase executeUpdate:sql];
    }


}


@end
