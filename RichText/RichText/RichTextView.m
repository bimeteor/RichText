//
//  QCRichTextView.m
//  RichText
//
//  Created by Laughing on 15/11/11.
//  Copyright © 2015年 frank. All rights reserved.
//
/*
 1.copy to here,plain->rich
 2.copy from here,rich->plain
 */
#import "RichTextView.h"
#import "RichLabel.h"

@interface RichTextView()<NSTextStorageDelegate>
{
}
@end

@implementation RichTextView

- (instancetype)initWithFrame:(CGRect)frame
{
    NSTextContainer *con = [NSTextContainer new];
    NSLayoutManager *layout = [NSLayoutManager new];
    [layout addTextContainer:con];
    NSTextStorage *store=[NSTextStorage new];
    [store addLayoutManager:layout];
    self = [super initWithFrame:frame textContainer:con];
    if (self)
    {
        store.delegate = self;
        self.textContainerInset = UIEdgeInsetsZero;
        self.textContainer.lineFragmentPadding = 0;
        super.font=[UIFont systemFontOfSize:17];
        super.textColor=[UIColor blackColor];
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [RichLabel new];
        });
    }
    return self;
}

/*
- (void)copy:(nullable id)sender {
    NSRange range = self.selectedRange;
    NSString *s = [self encodedStringInRange:range];
    [UIPasteboard generalPasteboard].string = s;
}

- (void)cut:(nullable id)sender {
    NSRange range = self.selectedRange;
    NSRange composedRange = [self composedRangeOfRange:range];
    NSString *s = [self encodedStringInComposedRange:composedRange];
    [UIPasteboard generalPasteboard].string = s;
    
    [self.textStorage deleteCharactersInRange:composedRange];
}

- (void)paste:(id)sender {
    NSRange range = self.selectedRange;
    NSRange composedRange = [self composedRangeOfRange:range];
    
    NSString *s = [UIPasteboard generalPasteboard].string;
    NSAttributedString *as = [self convertFromEncodedString:s];
    [self.textStorage replaceCharactersInRange:composedRange withAttributedString:as];
    self.selectedRange = NSMakeRange(composedRange.location + as.length, 0);
    
    [self setNeedsLayout];
}
*/
- (NSString*)text
{
    return self.textStorage.string;//TODO:frank
}

- (void)setText:(NSString *)text
{
    NSAttributedString *str=[self attributedStringFromString:text];
    [self.textStorage replaceCharactersInRange:NSMakeRange(0, self.textStorage.length) withAttributedString:str];
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
    [self.textStorage endEditing];
}

- (NSString*)stringFromAttributedString:(NSAttributedString*)attributedString
{
    NSMutableString *str=[NSMutableString new];
    return nil;
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
                if ([__icons containsObject:sub])
                {
                    NSTextAttachment *att=[[NSTextAttachment alloc] initWithData:nil ofType:nil];
                    att.image=[UIImage imageNamed:sub];
                    att.bounds=CGRectMake(0, self.font.descender, self.font.ascender-self.font.descender, self.font.ascender-self.font.descender);
                    NSAttributedString *atts=[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%CA", (unichar)NSAttachmentCharacter] attributes:@{NSAttachmentAttributeName:att, @"tag":sub}];
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

- (void)textStorage:(NSTextStorage *)textStorage willProcessEditing:(NSTextStorageEditActions)editedMask range:(NSRange)editedRange changeInLength:(NSInteger)delta
{
    if ((editedMask & NSTextStorageEditedCharacters)!=0)
    {
        NSString *plain=[textStorage attributedSubstringFromRange:editedRange].string;
        NSAttributedString *rich=[self attributedStringFromString:plain];
        [textStorage replaceCharactersInRange:editedRange withAttributedString:rich];
    }
}

@end
