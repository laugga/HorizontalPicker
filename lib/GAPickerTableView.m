/*
 
 GAPickerTableView.m
 GAPickerView
 
 Copyright (cc) 2012 Luis Laugga.
 Some rights reserved, all wrongs deserved.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of
 this software and associated documentation files (the "Software"), to deal in
 the Software without restriction, including without limitation the rights to
 use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 the Software, and to permit persons to whom the Software is furnished to do so,
 subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
*/

#import "GAPickerTableView.h"

@implementation GAPickerTableView

@synthesize dataSource=_dataSource;
@synthesize delegate=_delegate;

#pragma mark -
#pragma mark Initialization

#if !__has_feature(objc_arc)
- (void)dealloc
{
    [_panGestureRecognizer release];
    [super dealloc];
}
#endif

- (id)initWithFrame:(CGRect)frame andComponent:(NSInteger)component
{
    self = [super initWithFrame:frame];
    if(self)
    {
        _component = component;
        
        _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(userDidPan:)];
        [self addGestureRecognizer:_panGestureRecognizer];
    }
    return self;
}

#pragma mark -
#pragma mark UIView

- (void)layoutSubviews
{
    PrettyLog;
    
    CGPoint offset = CGPointZero;
    
    _numberOfColumns = 0;
    
    if(_dataSource)
    {
        _numberOfColumns = [_dataSource pickerTableView:self numberOfColumnsInComponent:_component];
        
        if(_delegate)
        {
            CGRect columnRect = CGRectMake(0, 0, 50.0, self.frame.size.height);
            
            for(int column=0; column<_numberOfColumns; ++column)
            {
                NSString * title = [_delegate pickerTableView:self titleForColumn:column forComponent:_component];
                
                UILabel * label = [[UILabel alloc] init];
                label.textColor = [UIColor whiteColor];
                label.text = title;
                label.textAlignment = UITextAlignmentCenter;
                label.frame = CGRectMake(offset.x, offset.y, columnRect.size.width, columnRect.size.height);
                [self addSubview:label];
                
                offset.x += columnRect.size.width;
            }
        }
    }
}

#pragma mark -
#pragma mark Pan Gesture

- (void)userDidPan:(UIPanGestureRecognizer *)panGesture
{
    //    // Long press position
    //    CGPoint position = [longPressGesture locationInView:self.view];
    //
    //    switch (longPressGesture.state) {
    //        case UIGestureRecognizerStateBegan:
    //        {
    //            // Being position change
    //            [_focusView beginPositionChangeForPoint:position];
    //
    //            // Start adjusting and metering
    //            [_camera setFocusPoint:CGPointMake((self.view.frame.size.width-position.x)/self.view.frame.size.width, position.y/self.view.frame.size.height) andStartMetering:YES];
    //        }
    //            break;
    //        case UIGestureRecognizerStateChanged:
    //        {
    //            // Change position
    //            _focusView.position = position;
    //        }
    //            break;
    //        case UIGestureRecognizerStateEnded:
    //        case UIGestureRecognizerStateCancelled:
    //        {
    //            // End position change
    //            [_focusView endPositionChange];
    //        }
    //            break;
    //        default:
    //            break;
    //    }
}

#pragma mark -
#pragma mark UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return NO;
}

@end
