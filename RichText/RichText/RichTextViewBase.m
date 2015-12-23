//
//  RichTextViewBase.m
//  RichText
//
//  Created by Laughing on 15/12/9.
//  Copyright © 2015年 frank. All rights reserved.
//

#import "RichTextViewBase.h"

NSString *gifs=@"002,005,006,010,011,014,019,020,021,026,038,044,097,098,099";
NSString *icons=@"001,002,003,004,005,006,007,008,009,010";
NSString *AttachmentTagAttributeName=@"AttachmentTagAttributeName";

NSSet *__pics;
NSSet *__gifs;
NSString *AttachmentCharacterString;

@interface RichTextViewBase()

@end

@implementation RichTextViewBase

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
        super.textContainerInset = UIEdgeInsetsZero;
        self.textContainer.lineFragmentPadding = 0;
        super.font=[UIFont systemFontOfSize:17];
        super.textColor=[UIColor blackColor];
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            __pics=[NSSet setWithArray:[icons componentsSeparatedByString:@","]];
            __gifs=[NSSet setWithArray:[gifs componentsSeparatedByString:@","]];
            AttachmentCharacterString=[NSString stringWithFormat:@"%C", (unichar)NSAttachmentCharacter];
        });
    }
    return self;
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
                if ([_richSymbols containsObject:sub])
                {
                    NSTextAttachment *att=[[NSTextAttachment alloc] initWithData:nil ofType:nil];
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

- (void)setTextContainerInset:(UIEdgeInsets)textContainerInset
{
    
}

- (NSString*)text
{
    return [self stringFromAttributedString:self.textStorage];
}

- (void)setText:(NSString *)text
{
    [self.textStorage replaceCharactersInRange:NSMakeRange(0, self.textStorage.length) withAttributedString:[[NSAttributedString alloc] initWithString:text]];
}

- (void)setTextColor:(UIColor *)textColor
{
    super.textColor=textColor;
    [self.textStorage beginEditing];
    [self.textStorage removeAttribute:NSForegroundColorAttributeName range:NSMakeRange(0, self.textStorage.length)];
    [self.textStorage addAttribute:NSForegroundColorAttributeName value:textColor range:NSMakeRange(0, self.textStorage.length)];
    [self.textStorage endEditing];
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
    super.font=font;
    [self.textStorage beginEditing];
    [self.textStorage removeAttribute:NSFontAttributeName range:NSMakeRange(0, self.textStorage.length)];
    [self.textStorage addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, self.textStorage.length)];
    
    long index=0;
    while (index<self.textStorage.length)
    {
        NSAttributedString *ch=[self.textStorage attributedSubstringFromRange:NSMakeRange(index, 1)];
        if ([ch.string isEqualToString:AttachmentCharacterString])
        {
            NSTextAttachment *att=[ch attribute:NSAttachmentAttributeName atIndex:0 effectiveRange:NULL];
            att.bounds=CGRectMake(0, font.descender, font.ascender-font.descender, font.ascender-font.descender);
        }
        ++index;
    }
    [self.textStorage endEditing];
}

- (void)copy:(id)sender
{
    [UIPasteboard generalPasteboard].string = [self stringFromAttributedString:[self.textStorage attributedSubstringFromRange:self.selectedRange]];
}

@end

@implementation NSAttributedString(Height)

- (float)heightForWidth:(float)width font:(UIFont*)font
{
    NSMutableAttributedString *att=[[NSMutableAttributedString alloc] initWithAttributedString:self];
    [att removeAttribute:NSFontAttributeName range:NSMakeRange(0, att.length)];
    [att addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, att.length)];
    long index=0;
    while (index<att.length)
    {
        NSAttributedString *ch=[att attributedSubstringFromRange:NSMakeRange(index, 1)];
        if ([ch.string isEqualToString:AttachmentCharacterString])
        {
            NSTextAttachment *att=[ch attribute:NSAttachmentAttributeName atIndex:0 effectiveRange:NULL];
            att.bounds=CGRectMake(0, font.descender, font.ascender-font.descender, font.ascender-font.descender);
        }
        ++index;
    }
    
    CGRect rect = [att boundingRectWithSize:CGSizeMake(width, HUGE_VALF) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading context:nil];
    return rect.size.height;
}

@end
