//
//  HintsPage.m
//  ProjectAlpha
//
//  Created by lanou3g on 11/11/15.
//  Copyright © 2015 com.sunshuaiqi. All rights reserved.
//

#import "HintsPage.h"

@implementation HintsPage


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    [AlphaIcons drawWelcomePageWithFrame:self.frame];
}


@end
