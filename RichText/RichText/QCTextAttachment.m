//
//  QCTextAttachment.m
//  RichText
//
//  Created by Laughing on 15/11/11.
//  Copyright © 2015年 frank. All rights reserved.
//

#import "QCTextAttachment.h"

@implementation QCTextAttachment

-(instancetype)initWithSize:(CGSize)size tag:(NSString*)tag
{
    self = [super initWithData:nil ofType:nil];
    if (self)
    {
        _tag = tag;
        self.bounds = CGRectMake(0, 0, size.width, size.height);
    }
    return self;
}

@end
