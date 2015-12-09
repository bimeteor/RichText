//
//  QCRichTextView.m
//  RichText
//
//  Created by Laughing on 15/11/11.
//  Copyright © 2015年 frank. All rights reserved.
//

#import "RichTextView.h"

@interface RichTextView()<NSTextStorageDelegate>
{
}
@end

@implementation RichTextView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.textStorage.delegate=self;
    }
    return self;
}

- (void)copy:(nullable id)sender
{
    [UIPasteboard generalPasteboard].string = [self stringFromAttributedString:[self.textStorage attributedSubstringFromRange:self.selectedRange]];
}

- (void)cut:(nullable id)sender
{
    [UIPasteboard generalPasteboard].string = [self stringFromAttributedString:[self.textStorage attributedSubstringFromRange:self.selectedRange]];
    [super cut:sender];
}

- (void)paste:(id)sender
{
    NSMutableString *str=[NSMutableString new];
    long left=0;
    long right=self.textStorage.length;
    if (self.selectedRange.location>3)
    {
        [str appendString:[self stringFromAttributedString:[self.textStorage attributedSubstringFromRange:NSMakeRange(self.selectedRange.location-3, 3)]]];
        left=self.selectedRange.location-3;
    }else if (self.selectedRange.location>0)
    {
        [str appendString:[self stringFromAttributedString:[self.textStorage attributedSubstringFromRange:NSMakeRange(0, self.selectedRange.location)]]];
    }
    [str appendString:[UIPasteboard generalPasteboard].string];
    if (NSMaxRange(self.selectedRange)<self.textStorage.length-3)
    {
        [str appendString:[self stringFromAttributedString:[self.textStorage attributedSubstringFromRange:NSMakeRange(NSMaxRange(self.selectedRange), 3)]]];
        right=NSMaxRange(self.selectedRange)+3;
    }else
    {
        [str appendString:[self stringFromAttributedString:[self.textStorage attributedSubstringFromRange:NSMakeRange(NSMaxRange(self.selectedRange), self.textStorage.length-self.selectedRange.location)]]];
    }
    [self.textStorage replaceCharactersInRange:NSMakeRange(left, right-left) withAttributedString:[self attributedStringFromString:str]];
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
                if ([__pics containsObject:sub])
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

- (void)textStorage:(NSTextStorage *)textStorage willProcessEditing:(NSTextStorageEditActions)editedMask range:(NSRange)editedRange changeInLength:(NSInteger)delta
{
    if ((editedMask & NSTextStorageEditedCharacters)!=0)
    {
        long right=MIN(NSMaxRange(editedRange)+3, textStorage.length);
        long left=MAX((long)editedRange.location-3, 0);
        NSRange range=NSMakeRange(left, right-left);
        NSString *plain=[self stringFromAttributedString:[textStorage attributedSubstringFromRange:range]];
        NSAttributedString *rich=[self attributedStringFromString:plain];
        [textStorage replaceCharactersInRange:range withAttributedString:rich];
    }
}

@end
