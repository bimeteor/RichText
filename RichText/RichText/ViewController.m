//
//  ViewController.m
//  RichText
//
//  Created by Laughing on 15/11/9.
//  Copyright © 2015年 frank. All rights reserved.
//

#import "ViewController.h"
#import "UIView+NSLayoutExtension.h"
#import "RichTextView.h"
#import "PathDrawingView.h"
#import "RichLabel.h"
#import "CircleContainer.h"

NSString *plain = @"你们还/002好吗啊史/021khb我是frank/014hbjk好想你们啊/044一起吃饭吧/006/099jkhbjkh大家觉得怎么样";
//NSString *plain = @"g/001j/009a你还好台球f/004asdfg/001j/009a你还好台球f/004asdf";

@interface Ellipse : UIView

@end

@implementation Ellipse

- (void)drawRect:(CGRect)rect
{
    [[UIColor blueColor] setFill];
    [[UIBezierPath bezierPathWithOvalInRect:self.bounds] fill];
}

@end

@interface ViewController ()
{
    UITextView *_view;
    Ellipse *_ball;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CircleContainer *con = [CircleContainer new];
    con.widthTracksTextView = YES;
    con.lineFragmentPadding = 0;
    NSLayoutManager *layout = [NSLayoutManager new];
    [layout addTextContainer:con];
    NSTextStorage *store=[NSTextStorage new];
    [store addLayoutManager:layout];
    
    _view=[[UITextView alloc] initWithFrame:CGRectMake(20, 50, 260, 260) textContainer:con];
    _view.backgroundColor=[UIColor yellowColor];
    _view.textContainerInset = UIEdgeInsetsZero;
    
    [self.view addSubview:_view];
    
    double st=CFAbsoluteTimeGetCurrent();
    NSAttributedString *string=[[NSAttributedString alloc] initWithString:@"Lorem iPsum dolor sit amet, consectetur adipiscing iPod. Phasellus magna dolor, volutpat a iPsum et, molestie justo. Vestibulum sed augue malesuada, congue iWork sed, fringilla ligula. Sed aliquet iCloud vestibulum. Phasellus gravida elit ut ligula vulputate fringilla. Pellentesque sit amet dolor pulvinar, dictum eros non, suscipit purus. Aenean metus mi, sodales ut augue in, varius sagittis mi. Sed semper est vel placerat scelerisque. In hac habitasse platea dictumst. Mauris auctor accumsan sagittis. Etiam interdum ante in condimentum iaculis. Aliquam porta facilisis lorem in auctor. Nullam non tortor eget urna iaculis faucibus et in augue. Integer nec libero placerat magna rhoncus ultrices eu venenatis massa. Suspendisse ullamcorper molestie lorem eget consequat." attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor], NSBackgroundColorAttributeName:[UIColor orangeColor]/*, NSTextEffectAttributeName:NSTextEffectLetterpressStyle*/}];
    [_view.textStorage replaceCharactersInRange:NSMakeRange(0, _view.textStorage.length) withAttributedString:string];
    NSLog(@"44  %f", CFAbsoluteTimeGetCurrent()-st);
    
    _ball=[[Ellipse alloc] initWithFrame:CGRectMake(60, 60, 100, 80)];
    [_view addSubview:_ball];
    _ball.backgroundColor=[UIColor clearColor];
    
    UIBezierPath *path=[UIBezierPath bezierPathWithOvalInRect:_ball.frame];
    _view.textContainer.exclusionPaths=@[path];
    
    UIPanGestureRecognizer *pan=[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [_view addGestureRecognizer:pan];
}

- (void)pan:(UIPanGestureRecognizer*)pan
{
    if (pan.state==UIGestureRecognizerStateBegan)
    {
        [pan setTranslation:CGPointZero inView:pan.view];
    }else if (pan.state==UIGestureRecognizerStateChanged)
    {
        CGPoint t=[pan translationInView:pan.view];
        _ball.center=CGPointMake(_ball.center.x+t.x, _ball.center.y+t.y);
        [pan setTranslation:CGPointZero inView:pan.view];
        UIBezierPath *path=[UIBezierPath bezierPathWithOvalInRect:_ball.frame];
        _view.textContainer.exclusionPaths=@[path];
    }
}

- (void)viewDidLoad1 {
    [super viewDidLoad];

    RichLabel *view = [[RichLabel alloc] initWithFrame:CGRectMake(90, 90, 200, 80)];
    [self.view addSubview:view];
    view.backgroundColor = [UIColor yellowColor];
    view.text=plain;
}

@end