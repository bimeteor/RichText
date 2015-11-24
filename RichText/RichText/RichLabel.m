//
//  RichLabel.m
//  RichText
//
//  Created by WG on 15/11/22.
//  Copyright © 2015年 frank. All rights reserved.
//

#import "RichLabel.h"
#import "GIFView.h"

NSString *gifs=@"002,005,006,010,011,014,019,020,021,026,038,044,097,098,099";
NSString *icons=@"001,002,003,004,005,006,007,008,009,010";
NSString *AttachmentTagAttributeName=@"AttachmentTagAttributeName";

NSSet *__icons;
NSSet *__gifs;
NSString *AttachmentCharacterString;

@interface RichLabel()<NSTextStorageDelegate>
{
    UIColor *_textColor;
    UIFont *_font;
    NSMutableArray *_GIFViews;
}
@end

@implementation RichLabel

- (instancetype)initWithFrame:(CGRect)frame
{
    NSLayoutManager *layout = [NSLayoutManager new];
    NSTextStorage *store=[NSTextStorage new];
    [store addLayoutManager:layout];
    NSTextContainer *con = [NSTextContainer new];
    con.widthTracksTextView = YES;
    [layout addTextContainer:con];
    self = [super initWithFrame:frame textContainer:con];
    if (self)
    {
        self.textContainerInset = UIEdgeInsetsZero;
        self.textContainer.lineFragmentPadding = 0;
        _font=[UIFont systemFontOfSize:17];
        _textColor=[UIColor blackColor];
        super.editable = NO;
        _GIFViews=[NSMutableArray new];

        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            __icons=[NSSet setWithArray:[icons componentsSeparatedByString:@","]];
            __gifs=[NSSet setWithArray:[gifs componentsSeparatedByString:@","]];
            AttachmentCharacterString=[NSString stringWithFormat:@"%C", (unichar)NSAttachmentCharacter];
        });
    }
    return self;
}

- (NSString*)text
{
    return [self stringFromAttributedString:self.textStorage];
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

- (NSString*)stringFromAttributedString:(NSAttributedString*)attributedString
{
    NSMutableString *str=[NSMutableString new];
    long index=0;
    NSAttributedString *ch;
    while (index<attributedString.length)
    {
        ch=[attributedString attributedSubstringFromRange:NSMakeRange(index, 1)];
        NSString *tag=[ch attribute:AttachmentTagAttributeName atIndex:0 effectiveRange:NULL];
        if ([ch.string isEqualToString:AttachmentCharacterString] && tag)
        {
            [str appendFormat:@"/%@", tag];
        }else
        {
            [str appendString:ch.string];
        }
        ++index;
    }
    return str;
}

- (void)setTextColor:(UIColor *)textColor
{
    _textColor=textColor;
    super.textColor=textColor;
    [self.textStorage beginEditing];
    [self.textStorage removeAttribute:NSForegroundColorAttributeName range:NSMakeRange(0, self.textStorage.length)];
    [self.textStorage addAttribute:NSForegroundColorAttributeName value:textColor range:NSMakeRange(0, self.textStorage.length)];
    [self.textStorage endEditing];
}

- (UIColor*)textColor
{
    return _textColor;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    super.backgroundColor=backgroundColor;
    [self.textStorage beginEditing];
    [self.textStorage removeAttribute:NSBackgroundColorAttributeName range:NSMakeRange(0, self.textStorage.length)];
    [self.textStorage addAttribute:NSBackgroundColorAttributeName value:backgroundColor range:NSMakeRange(0, self.textStorage.length)];
    [self.textStorage endEditing];
}

- (void)setFont:(UIFont *)font
{
    _font=font;
    super.font=font;
    [self.textStorage beginEditing];
    [self.textStorage removeAttribute:NSFontAttributeName range:NSMakeRange(0, self.textStorage.length)];
    [self.textStorage addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, self.textStorage.length)];
    [self.textStorage endEditing];
}

- (UIFont*)font
{
    return _font;
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
