//
//  RichTextViewBase.h
//  RichText
//
//  Created by Laughing on 15/12/9.
//  Copyright © 2015年 frank. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSSet *__pics;
extern NSSet *__gifs;
extern NSString *AttachmentCharacterString;
extern NSString *AttachmentTagAttributeName;

@interface RichTextViewBase : UITextView
{
    NSSet *_richSymbols;
}

- (NSString*)stringFromAttributedString:(NSAttributedString*)attributedString;
- (NSAttributedString*)attributedStringFromString:(NSString*)string;

@end


@interface NSAttributedString(Height)

@end