//
//  PathDrawingView.h
//  Drag
//
//  Created by frankgwang on 13-9-9.
//  Copyright (c) 2013年  WG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PathDrawingView : UIView
@property (nonatomic, strong) UIBezierPath *bezierPath;
@property (nonatomic, strong) UIColor *strokeColor;
@property (nonatomic) float lineWidth;
@property (nonatomic) float duration;
- (void)startAnimation;
- (void)stopAnimation;
@end
