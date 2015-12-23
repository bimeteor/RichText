//
//  RichLabel.m
//  RichText
//
//  Created by WG on 15/11/22.
//  Copyright © 2015年 frank. All rights reserved.
//

#import "RichLabel.h"
#import "GIFView.h"

@interface RichLabel()
{
    UIColor *_textColor;
    UIFont *_font;
    NSMutableArray *_GIFViews;
}
@end

@implementation RichLabel

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _font=[UIFont systemFontOfSize:17];
        _textColor=[UIColor blackColor];
        super.editable = NO;
        _GIFViews=[NSMutableArray new];
        _richSymbols=__gifs;
    }
    return self;
}

- (void)setText:(NSString *)text
{
    NSAttributedString *str=[self attributedStringFromString:text];
    [self.textStorage replaceCharactersInRange:NSMakeRange(0, self.textStorage.length) withAttributedString:str];
    [_GIFViews makeObjectsPerformSelector:@selector(removeFromSuperview)];

    for (long index=0; index<self.textStorage.length; ++index)
    {
        NSAttributedString *ch=[self.textStorage attributedSubstringFromRange:NSMakeRange(index, 1)];
        NSString *tag=[ch attribute:AttachmentTagAttributeName atIndex:0 effectiveRange:NULL];
        if ([ch.string isEqualToString:AttachmentCharacterString] && tag)
        {
            CGRect rect = [self.layoutManager boundingRectForGlyphRange:NSMakeRange(index, 1) inTextContainer:self.textContainer];
            long index = [_GIFViews indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                if (![obj superview])
                {
                    *stop = YES;
                    return YES;
                }else
                {
                    return NO;
                }
            }];
            GIFView *view;
            if (index!=NSNotFound)
            {
                view = _GIFViews[index];
            }else
            {
                view = [GIFView new];
                [_GIFViews addObject:view];
            }
            [self addSubview:view];
            view.frame = rect;
            NSString *path=[[NSBundle mainBundle] pathForResource:[tag stringByAppendingString:@"@2x"] ofType:@"gif"];
            NSData *data=[NSData dataWithContentsOfFile:path];
            view.GIFData=data;
            [view startAnimation];
        }
    }
}

- (UIColor*)textColor
{
    return _textColor;
}

- (void)setTextColor:(UIColor *)textColor
{
    _textColor=textColor;
    super.textColor=textColor;
}

- (UIFont*)font
{
    return _font;
}

- (void)setFont:(UIFont *)font
{
    _font=font;
    super.font=font;
}

- (void)setEditable:(BOOL)editable
{
    
}

@end
