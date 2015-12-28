//
//  ViewController.m
//  RichText
//
//  Created by Laughing on 15/11/9.
//  Copyright © 2015年 frank. All rights reserved.
//

#import "ViewController.h"
#import "UIView+NSLayoutExtension.h"
#import "RichTextView.h"
#import "PathDrawingView.h"
#import "RichLabel.h"

static NSString *plain = @"g/001j/009a你还好台球f/004asdfg/001j/009a你还好台球f/004asdf";

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    RichTextView *view = [[RichTextView alloc] initWithFrame:CGRectMake(20, 90, 150, 260)];
    [self.view addSubview:view];
    view.backgroundColor = [UIColor yellowColor];
    view.text=plain;
    /*
    UIImage *image1=[UIImage imageNamed:@"11.jpeg"];
    UIImage *image2=[UIImage imageNamed:@"22"];
    UIGraphicsBeginImageContext(CGSizeMake(360, 200));
    CGContextRef ctx=UIGraphicsGetCurrentContext();
    [image1 drawInRect:CGRectMake(0, 0, 180, 200)];
    [image2 drawInRect:CGRectMake(180, 0, 180, 200)];
    UIImage *img=UIGraphicsGetImageFromCurrentImageContext();
    */
    
}

@end