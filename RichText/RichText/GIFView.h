//
//  GIFView.h
//  GIFView
//
//  Created by frankgwang on 13-9-8.
//  Copyright (c) 2013年 Tencent SNS Terminal Develope Center. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GIFView : UIView
@property (nonatomic, strong) NSData *GIFData;
@property (nonatomic) float repeatCount;
@property (nonatomic) float totalDuration;
- (void)startAnimation;
- (void)stopAnimation;
@end
