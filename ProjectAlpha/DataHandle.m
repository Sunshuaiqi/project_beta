//
//  DataHandle.m
//  ProjectAlpha
//
//  Created by Sunshuaiqi on 10/30/15.
//  Copyright © 2015 com.sunshuaiqi. All rights reserved.
//

#import "DataHandle.h"
#import "SideBarViewController.h"

#import "FavoriteModel.h"
#import <AVOSCloud.h>

@interface DataHandle ()

@property (nonatomic,strong) NSMutableArray * array; // 存放查询结果的数组

@end

@implementation DataHandle

+ (instancetype)SharedData{
    
    static DataHandle *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [self new];
    });
    
    return sharedManager;
}


#pragma mark -- 创建数据库
- (void)createDB
{
    
    // 找到document的路径
    NSString * documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    
    // 数据库存放地址
    NSString * filePath = [documentPath stringByAppendingPathComponent:@"History.db"];
    
    
    // 创建数据库
    self.dataBase = [FMDatabase databaseWithPath:filePath];
    
    print(@"数据库所在路径：%@",filePath);
    
    // 打开数据库的情况
    if ([self.dataBase open]) {
        
        print(@"数据库创建成功");
        
        // 创建表 (列名，类型)
        // （1）存放文章的表  (根据当前用户名创建表名)
        NSString * tableName = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (ID text PRIMARY KEY , title TEXT, imageUrl TEXT,paragraph TEXT,time TEXT);",[AVUser currentUser].username];
        
        BOOL result =  [self.dataBase executeUpdate:tableName];
        
        if (result) {
            print(@"成功建表（浏览）");
        } else {
            
            print(@"建表失败");
        }
    }
    
}


#pragma mark -- 向表中添加数据
- (void)insertDataWithID:(NSString *)ID title:(NSString *)title imgUrl:(NSString *)imgUrl paragraph:(NSString *)paragraph time:(NSString *)time
{
    
    [self createDB];
    
    if ([self.dataBase open]) {
        
        NSMutableArray * array = [self qureyData];
        
        for (FavoriteModel * model in array) {
            
            if ([model.ID isEqualToString:ID]) {
                print(@"之前浏览过了");
                
                NSString * updateSql = [NSString stringWithFormat:@"update %@ set time = ? where ID = ?",[AVUser currentUser].username];
                [self.dataBase executeUpdate:updateSql,time,ID];
                
                [self.dataBase close];
                
                return;
            }
        }
        
        // 数据库中没有浏览过，就收藏
        // 添加数据
        NSString * insertTableName = [NSString stringWithFormat:@"insert into %@ (ID,title,imageUrl,paragraph,time) values (?,?,?,?,?)",[AVUser currentUser].username];
        
        [self.dataBase executeUpdate:insertTableName, ID, title,imgUrl,paragraph,time];
        
        print(@"添加浏览成功");
        
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
        FMResultSet * resultSet = [self.dataBase executeQuery:[NSString stringWithFormat:@"select * from %@ order by time desc",[AVUser currentUser].username]];
        
        // 遍历结果
        while ([resultSet next]) {
            FavoriteModel * model = [FavoriteModel new];
            NSString * ID = [resultSet stringForColumn:@"ID"];
            NSString * title = [resultSet stringForColumn:@"title"];
            NSString * imgUrl = [resultSet stringForColumn:@"imageUrl"];
            NSString * paragraph = [resultSet stringForColumn:@"paragraph"];
            NSString * time = [resultSet stringForColumn:@"time"];
            
            // 赋值给model
            
            model.ID = ID;
            model.titleStr = title;
            model.imgUrl = imgUrl;
            model.paragraph = paragraph;
            model.BrowseTime = time;
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

// 删除数据库中所有的元素
- (void)deleteAllData
{
    [self createDB];
    if ([self.dataBase open]) {
        
        NSString * sql = [NSString stringWithFormat:@"delete from %@",[AVUser currentUser].username];
        
        [self.dataBase executeUpdate:sql];
    }


}

// 单个文件大小
- (long long) fileSizeAtPath:(NSString*) filePath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}
//遍历文件夹获得文件夹大小，返回多少M
- (float )folderSizeAtPath:(NSString*) folderPath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath]) return 0;
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    NSString* fileName;
    long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        folderSize += [self fileSizeAtPath:fileAbsolutePath];
    }
    return folderSize/(1024.0*1024.0);
}

- (void)clearCache {
    
    NSString *cachPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask, YES) objectAtIndex:0];
    
    NSArray *files = [[NSFileManager defaultManager] subpathsAtPath:cachPath];
    // NSLog(@"files :%ld",[files count]);
    for (NSString *p in files) {
        NSError *error;
        NSString *path = [cachPath stringByAppendingPathComponent:p];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
        }
        
    }

}
@end
