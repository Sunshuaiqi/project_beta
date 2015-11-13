//
//  WaterFlowLayout.m
//  ProjectAlpha
//
//  Created by lanou3g on 15/10/25.
//  Copyright © 2015年 com.sunshuaiqi. All rights reserved.
//

#import "WaterFlowLayout.h"

@interface WaterFlowLayout ()

@property(nonatomic,strong) NSMutableDictionary * maxYdic;

@end


@implementation WaterFlowLayout

-(NSMutableDictionary *)maxYdic
{
    if (!_maxYdic) {
        self.maxYdic = [[NSMutableDictionary alloc] init];
    }
    return _maxYdic;
}
-(instancetype)init
{
    if (self=[super init]) {
        self.colMagrin = 5;
        self.rowMagrin = 2.5;
        self.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
        self.colCount = 2;
    }
    return self;
}

-(void)prepareLayout
{
    [super prepareLayout];
    
    
}
-(BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}
-(CGSize)collectionViewContentSize
{
    __block NSString * maxCol = @"0";
    //找出最短的列
    [self.maxYdic enumerateKeysAndObjectsUsingBlock:^(NSString * column, NSNumber *maxY, BOOL *stop) {
        if ([maxY floatValue]>[self.maxYdic[maxCol] floatValue]) {
            maxCol = column;
        }
    }];
    return CGSizeMake(0, [self.maxYdic[maxCol] floatValue]);
}
-(UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    __block NSString * minCol = @"0";
    //找出最短的列
    [self.maxYdic enumerateKeysAndObjectsUsingBlock:^(NSString * column, NSNumber *maxY, BOOL *stop) {
        if ([maxY floatValue]<[self.maxYdic[minCol] floatValue]) {
            minCol = column;
        }
    }];
    //    计算宽度
    CGFloat width = (self.collectionView.frame.size.width-self.sectionInset.left-self.sectionInset.right-(self.colCount-1)*self.colMagrin)/self.colCount;
    //    计算高度
    CGFloat hight = [self.delegate waterFlow:self heightForWidth:width atIndexPath:indexPath];
   
    
    CGFloat x = self.sectionInset.left + (width+ self.colMagrin)* [minCol intValue];
    CGFloat y =[self.maxYdic[minCol] floatValue]+self.rowMagrin;
    //    更新最大的y值
    self.maxYdic[minCol] = @(y+hight);
    
    //    计算位置
    UICollectionViewLayoutAttributes * attribute =[UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attribute.frame = CGRectMake(x, y, width, hight);
    return attribute;

}



-(NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    for(int i = 0;i<self.colCount;i++)
    {
        NSString * col = [NSString stringWithFormat:@"%d",i];
        self.maxYdic[col] = @0;
    }
    
    
    
    NSMutableArray * array = [NSMutableArray array];
    NSInteger count = [self.collectionView numberOfItemsInSection:0];
    for (int i = 0; i < count; i++) {
        UICollectionViewLayoutAttributes * attrs = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
        [array addObject:attrs];
    }
    return  array;
}

@end
