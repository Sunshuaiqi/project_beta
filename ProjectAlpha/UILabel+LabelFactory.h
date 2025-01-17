//
//  UILabel+LabelFactory.h
//  ProjectAlpha
//
//  Created by lanou3g on 11/2/15.
//  Copyright © 2015 com.sunshuaiqi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (LabelFactory)
+ (UILabel *)modernLabelWithTitle:(NSString *)title Color:(UIColor *)color OnView:(UIView *)view;
+ (UILabel *)modernLabelLowerPlateWithTitle:(NSString *)title Color:(UIColor *)color OnView:(UIView *)view;
+ (UILabel *)modernFacilitateLabelWithTitle:(NSString *)title Color:(UIColor *)color OnView:(UIView *)view Centered:(BOOL)centered;
@end
