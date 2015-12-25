//
//  LabelController.m
//  RichText
//
//  Created by Laughing on 15/12/24.
//  Copyright © 2015年 frank. All rights reserved.
//

#import "LabelController.h"
#import "RichLabel.h"
#import "GIFView.h"
static NSString *plain = @"你们还/002好吗啊史/021khb我是frank/014hbjk好想你们啊/044一起吃饭吧/006/099jkhbjkh大家觉得怎么样";

@implementation LabelController

- (void)viewDidLoad
{
    [super viewDidLoad];
    RichLabel *view = [[RichLabel alloc] initWithFrame:CGRectMake(20, 90, 260, 260)];
    [self.view addSubview:view];
    view.backgroundColor = [UIColor yellowColor];
    view.text=plain;
    view.font=[UIFont systemFontOfSize:30];
    view.tag=1;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    for (GIFView *view in [[self.view viewWithTag:1] subviews])
    {
        if ([view isKindOfClass:[GIFView class]])
        {
            [view startAnimation];
        }
        
    }
}

@end
