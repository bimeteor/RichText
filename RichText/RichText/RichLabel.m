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
    }
    return self;
}

- (void)setText:(NSString *)text
{
    NSAttributedString *str=[self attributedStringFromString:text];
    [self.textStorage replaceCharactersInRange:NSMakeRange(0, self.textStorage.length) withAttributedString:str];
    [_GIFViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    long index=0;
    NSAttributedString *ch;
    while (index<self.textStorage.length)
    {
        ch=[self.textStorage attributedSubstringFromRange:NSMakeRange(index, 1)];
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
        ++index;
    }
}

- (NSAttributedString*)attributedStringFromString:(NSString*)string
{
    NSMutableAttributedString *str = [NSMutableAttributedString new];
    long index = 0;
    NSString *ch;
    while (index<string.length)
    {
        ch=[string substringWithRange:NSMakeRange(index, 1)];
        if ([ch isEqualToString:@"/"])
        {
            if (index+3<string.length)
            {
                NSString *sub=[string substringWithRange:NSMakeRange(index+1, 3)];
                if ([__gifs containsObject:sub])
                {
                    NSTextAttachment *att=[[NSTextAttachment alloc] initWithData:nil ofType:nil];
                    att.image=[UIImage imageNamed:sub];
                    att.bounds=CGRectMake(0, self.font.descender, self.font.ascender-self.font.descender, self.font.ascender-self.font.descender);
                    NSAttributedString *atts=[[NSAttributedString alloc] initWithString:AttachmentCharacterString attributes:@{NSAttachmentAttributeName:att, AttachmentTagAttributeName:sub}];
                    [str appendAttributedString:atts];
                    index+=4;
                }else
                {
                    ++index;
                }
            }else
            {
                [str replaceCharactersInRange:NSMakeRange(str.length, 0) withString:[string substringFromIndex:index]];
                break;
            }
        }else
        {
            [str replaceCharactersInRange:NSMakeRange(str.length, 0) withString:ch];
            ++index;
        }
    }
    [str addAttribute:NSForegroundColorAttributeName value:self.textColor range:NSMakeRange(0, str.length)];
    [str addAttribute:NSBackgroundColorAttributeName value:self.backgroundColor range:NSMakeRange(0, str.length)];
    [str addAttribute:NSFontAttributeName value:self.font range:NSMakeRange(0, str.length)];
    
    return str;
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

/*
 - (float)heightWithWidth:(float)width font:(UIFont*)font
 {
 NSMutableAttributedString *att=[[NSMutableAttributedString alloc] initWithAttributedString:self];
 [att enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, self.length) options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
 if (value)
 {
 [value setBounds:CGRectMake(0, 0, font.pointSize, font.pointSize)];
 }
 }];
 [att removeAttribute:NSFontAttributeName range:NSMakeRange(0, att.length)];
 [att addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, att.length)];
 CGRect rect = [att boundingRectWithSize:CGSizeMake(width, HUGE_VALF) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading context:nil];
 return rect.size.height;
 }

 */
/*
- (void)copy:(nullable id)sender {
    NSRange range = self.selectedRange;
    NSString *s = [self encodedStringInRange:range];
    [UIPasteboard generalPasteboard].string = s;
}
*/
@end
