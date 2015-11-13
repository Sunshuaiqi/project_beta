//
//  MovieModel.h
//  ProjectAlpha
//
//  Created by lanou3g on 15/10/22.
//  Copyright © 2015年 com.sunshuaiqi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MovieModel : NSObject
@property (nonatomic,assign)NSInteger id;
@property (nonatomic,strong)NSString * contentId;
@property (nonatomic,strong)NSString * subtitle;
@property (nonatomic,strong)NSString * title;
@property (nonatomic,strong)NSString * picUrl;
@property (nonatomic,strong)NSString * tag;

@end
