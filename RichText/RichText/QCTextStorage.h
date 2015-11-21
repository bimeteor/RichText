//
//  QCTextStorage.h
//  RichText
//
//  Created by Laughing on 15/11/11.
//  Copyright © 2015年 frank. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QCTextStorage : NSTextStorage
- (float)heightWithWidth:(float)width font:(UIFont*)font;
@end


@interface NSString(QC)
- (NSAttributedString*)attributedString;
@end