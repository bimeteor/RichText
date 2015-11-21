//
//  QCTextStorage.m
//  RichText
//
//  Created by Laughing on 15/11/11.
//  Copyright © 2015年 frank. All rights reserved.
//

#import "QCTextStorage.h"
#import "QCTextAttachment.h"

NSString *gifs=@"002,005,006,010,011,014,019,020,021,026,038,044,097,098,099";


@interface QCTextStorage()
{
    NSMutableAttributedString *_impl;
}

@end

@implementation QCTextStorage

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _impl = [NSMutableAttributedString new];
        
    }
    return self;
}

#pragma mark - open

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

#pragma mark - subclass

- (NSString *)string
{
    return _impl.string;
}

- (NSDictionary *)attributesAtIndex:(NSUInteger)location effectiveRange:(NSRangePointer)range
{
    return [_impl attributesAtIndex:location effectiveRange:range];
}

- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)str
{
    NSString *tmp=_impl.string;
    tmp=[tmp stringByAppendingString:str];
    NSAttributedString *att=tmp.attributedString;
    long len=_impl.length;
    [_impl replaceCharactersInRange:NSMakeRange(0, _impl.length) withAttributedString:att];
    [self edited:NSTextStorageEditedCharacters range:NSMakeRange(0, len) changeInLength:_impl.length-len];
}

- (void)setAttributes:(NSDictionary *)attrs range:(NSRange)range
{
    [_impl setAttributes:attrs range:range];
    [self edited:NSTextStorageEditedAttributes range:range changeInLength:0];
}

@end


@implementation NSString(QC)

- (NSAttributedString*)attributedString
{
    NSArray *_gifs=[gifs componentsSeparatedByString:@","];
    NSMutableAttributedString *string = [NSMutableAttributedString new];
    [string addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:20] range:NSMakeRange(0, string.length)];
    long index = 0;
    while (index<self.length)
    {
        NSString *ch=[self substringWithRange:NSMakeRange(index, 1)];
        if ([ch isEqualToString:@"/"])
        {
            if (index+3<self.length)
            {
                NSString *sub=[self substringWithRange:NSMakeRange(index+1, 3)];
                if ([_gifs containsObject:sub])
                {
                    CGSize size = CGSizeMake([UIFont systemFontOfSize:20].pointSize, [UIFont systemFontOfSize:20].pointSize);
                    QCTextAttachment *att=[[QCTextAttachment alloc] initWithSize:size tag:sub];
                    [string appendAttributedString:[NSAttributedString attributedStringWithAttachment:att]];
                    index+=4;
                }else
                {
                    ++index;
                }
            }else
            {
                [string replaceCharactersInRange:NSMakeRange(string.length, 0) withString:[self substringFromIndex:index]];
                break;
            }
        }else
        {
            [string replaceCharactersInRange:NSMakeRange(string.length, 0) withString:ch];
            ++index;
        }
    }
    return string;
}

@end