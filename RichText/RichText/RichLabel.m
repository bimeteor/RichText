//
//  RichLabel.m
//  RichText
//
//  Created by WG on 15/11/22.
//  Copyright © 2015年 frank. All rights reserved.
//

#import "RichLabel.h"
#import "QCTextStorage.h"
#import "GIFView.h"

@interface RichLabel()<NSTextStorageDelegate>
{
    NSMutableArray *_GIFViews;
}
@end

@implementation RichLabel

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
        _GIFViews=[NSMutableArray new];
    }
    return self;
}

- (NSString*)text
{
    return self.textStorage.string;//TODO:frank
}

- (void)setText:(NSString *)text
{
    NSAttributedString *str=[self attributedStringFromString:text];
    [self.textStorage replaceCharactersInRange:NSMakeRange(0, self.textStorage.length) withAttributedString:str];
    /*
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
            NSString *path=[[NSBundle mainBundle] pathForResource:[[(QCTextAttachment*)value tag] stringByAppendingString:@"@2x"] ofType:@"gif"];
            NSData *data=[NSData dataWithContentsOfFile:path];
            view.GIFData=data;
            [view startAnimation];
        }
    }];*/
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

- (NSAttributedString*)attributedStringFromString:(NSString*)string
{
    //TODO:frank 目前比较用字符串匹配
    NSArray *_icons=[icons componentsSeparatedByString:@","];//TODO:frank
    NSMutableAttributedString *str = [NSMutableAttributedString new];
    long index = 0;
    while (index<string.length)
    {
        NSString *ch=[string substringWithRange:NSMakeRange(index, 1)];
        if ([ch isEqualToString:@"/"])
        {
            if (index+3<string.length)
            {
                NSString *sub=[string substringWithRange:NSMakeRange(index+1, 3)];
                if ([_icons containsObject:sub])
                {
                    CGSize size = CGSizeMake(self.font.pointSize, self.font.pointSize);
                    NSTextAttachment *att=[[NSTextAttachment alloc] initWithData:nil ofType:nil];
                    att.image=[UIImage imageNamed:sub];
                    att.bounds=CGRectMake(0, 0, size.width, size.height);//TODO:frank
                    NSAttributedString *atts=[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%uA", NSAttachmentCharacter] attributes:@{NSAttachmentAttributeName:att, @"tag":sub}];
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

/*
- (void)copy:(nullable id)sender {
    NSRange range = self.selectedRange;
    NSString *s = [self encodedStringInRange:range];
    [UIPasteboard generalPasteboard].string = s;
}
*/
@end
