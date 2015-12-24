//
//  CircleContainer.m
//  RichText
//
//  Created by Laughing on 15/12/23.
//  Copyright © 2015年 frank. All rights reserved.
//

#import "CircleContainer.h"

@implementation CircleContainer

-(CGRect)lineFragmentRectForProposedRect:(CGRect)proposedRect atIndex:(NSUInteger)characterIndex writingDirection:(NSWritingDirection)baseWritingDirection remainingRect:(CGRect *)remainingRect
{
    CGRect rect = [super lineFragmentRectForProposedRect:proposedRect atIndex:characterIndex writingDirection:baseWritingDirection remainingRect:remainingRect];
    float R=fminf(proposedRect.size.width, self.size.width)/2;
    float y=proposedRect.origin.y+proposedRect.size.height/2;
    float r=sqrtf(y*fabsf(R*2-y));
    r=fmaxf(r, 10);
    return CGRectIntersection(rect, CGRectMake(R-r, proposedRect.origin.y, r*2, proposedRect.size.height));
}

@end
