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
#import "QCRichTextView.h"
#import "GIFView.h"

@interface QCRichTextView()<NSTextStorageDelegate>
{
    NSMutableArray *_GIFViews;
}
@end

@implementation QCRichTextView

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
        self.textContainerInset = UIEdgeInsetsZero;
        self.textContainer.lineFragmentPadding = 0;
        store.delegate = self;
        _GIFViews = [NSMutableArray new];
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
    //[self.textStorage replaceCharactersInRange:NSMakeRange(0, self.textStorage.length) withAttributedString:text.attributedString];
    self.textColor=self.textColor;
    self.font=self.font;
    self.backgroundColor=self.backgroundColor;
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
    if (font)
    {
        [self.textStorage beginEditing];
        [self.textStorage removeAttribute:NSFontAttributeName range:NSMakeRange(0, self.textStorage.length)];
        [self.textStorage addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, self.textStorage.length)];
        [self.textStorage endEditing];
    }
}

- (void)textStorage:(NSTextStorage *)textStorage willProcessEditing:(NSTextStorageEditActions)editedMask range:(NSRange)editedRange changeInLength:(NSInteger)delt
{
    
}

- (void)textStorage:(NSTextStorage *)textStorage didProcessEditing:(NSTextStorageEditActions)editedMask range:(NSRange)editedRange changeInLength:(NSInteger)delta
{
    for (UIView *view in _GIFViews)
    {
        [view removeFromSuperview];
    }
    
    [self.textStorage enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, self.textStorage.length) options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
        if (value)
        {
            CGRect rect = [self.layoutManager boundingRectForGlyphRange:range inTextContainer:self.textContainer];
            rect = CGRectMake(rect.origin.x, rect.origin.y-self.font.descender, rect.size.width, rect.size.height);
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
            //view.backgroundColor=[UIColor blueColor];
            NSString *path=nil;//[[NSBundle mainBundle] pathForResource:[[(QCTextAttachment*)value tag] stringByAppendingString:@"@2x"] ofType:@"gif"];
            NSData *data=[NSData dataWithContentsOfFile:path];
            view.GIFData=data;
            [view startAnimation];
        }
    }];
}

@end
