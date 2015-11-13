//
//  MediaDetailsViewController.h
//  ProjectAlpha
//
//  Created by lanou3g on 15/10/26.
//  Copyright © 2015年 com.sunshuaiqi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

@interface MediaDetailsViewController : UIViewController<AVPlayerViewControllerDelegate>
@property (nonatomic,strong)NSString *movieID;
@property (nonatomic,strong)NSString *movieImgUrl;
@property (nonatomic,strong)NSString  *midid;
@end
