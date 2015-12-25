//
//  PathController.m
//  RichText
//
//  Created by Laughing on 15/12/24.
//  Copyright © 2015年 frank. All rights reserved.
//

#import "PathController.h"
#import "CircleContainer.h"

@interface Ellipse : UIView

@end

@implementation Ellipse

- (void)drawRect:(CGRect)rect
{
    [[UIColor blueColor] setFill];
    [[UIBezierPath bezierPathWithOvalInRect:self.bounds] fill];
    [@"Drag me!" drawAtPoint:CGPointMake(self.bounds.size.width/2-35, self.bounds.size.height/2-12) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18], NSForegroundColorAttributeName:[UIColor whiteColor]}];
}

@end

@interface PathController ()
{
    UITextView *_view;
    Ellipse *_ball;
}
@end

@implementation PathController

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

@end
