//
//  QCTextAttachment.h
//  RichText
//
//  Created by Laughing on 15/11/11.
//  Copyright © 2015年 frank. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QCTextAttachment : NSTextAttachment
@property (nonatomic) NSString *tag;
-(instancetype)initWithSize:(CGSize)size tag:(NSString*)tag;
@end
