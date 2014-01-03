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

@synthesize selectedColumn=_selectedColumn;

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
        
        _selectedTranslation = frame.size.width-55.0f;
    }
    return self;
}

#pragma mark -
#pragma mark Layout

- (void)layoutSubviews
{
    PrettyLog;
    
    if(_columns == nil)
    {
        CGPoint offset = CGPointZero;
        
        _numberOfColumns = 0;
        _absoluteTranslation = 0.0f;
        
        if(_dataSource)
        {
            _numberOfColumns = [_dataSource pickerTableView:self numberOfColumnsInComponent:_component];
            _columns = [[NSMutableArray alloc] initWithCapacity:_numberOfColumns];
            
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
                    [_columns addObject:label];
                    
                    [self addSubview:label];
                    
                    offset.x += columnRect.size.width;
                }
            }
        }
    }
}

- (void)updateLayoutSubviews
{
    //NSNumber * translation = @(_selectedColumn * -50.0);
    CGFloat currentTranslation = _absoluteTranslation + _scrollingTranslation;
    NSNumber * layerTranslation = @(currentTranslation);
    for(UILabel * column in _columns)
    {
        [column.layer setValue:layerTranslation forKeyPath:@"transform.translation.x"];
    }
}

- (void)setSelectedColumn:(NSInteger)column animated:(BOOL)animated
{
    Log(@"setSelectedColumn: %d", column);
    
    _selectedColumn = column;
    _absoluteTranslation = _selectedTranslation-_selectedColumn*50.0;
    
    if(animated)
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
    }
    
    NSNumber * layerTranslation = @(_absoluteTranslation);
    for(UILabel * column in _columns)
    {
        [column.layer setValue:layerTranslation forKeyPath:@"transform.translation.x"];
    }
    
    if(animated)
    {
        [UIView commitAnimations];
    }
    
//    NSNumber * layerTranslation = @(_absoluteTranslation);
//    for(UILabel * column in _columns)
//    {
//        CABasicAnimation * translationAnimation;
//        translationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
//        translationAnimation.duration = 4.0;
//        translationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//        translationAnimation.fillMode = kCAFillModeForwards;
//        translationAnimation.toValue = layerTranslation;
//        [column.layer addAnimation:translationAnimation forKey:@"transform.translation.x"];
//    }
}

#pragma mark -
#pragma mark Pan Gesture

- (void)userDidPan:(UIPanGestureRecognizer *)panGesture
{
    switch (panGesture.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            _isScrolling = YES;
            
            _scrollingTranslation = [panGesture translationInView:self].x;
            [self updateLayoutSubviews];
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            _scrollingTranslation = [panGesture translationInView:self].x;
            [self updateLayoutSubviews];
            
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            _scrollingTranslation = [panGesture translationInView:self].x;
            [self updateLayoutSubviews];
            
            _isScrolling = NO;
            _absoluteTranslation = _absoluteTranslation + _scrollingTranslation;
            
            NSInteger columnIndex=0;
            for(UILabel * column in _columns)
            {
                CGFloat columnTranslation = -column.frame.origin.x;
                CGFloat offset = (columnTranslation + _selectedTranslation);
                if(offset < 30.0f && offset > -30.0f)
                {
                    [self setSelectedColumn:columnIndex animated:YES];
                    break;
                }
                columnIndex+=1;
            }
        }
            break;
        default:
            break;
    }
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
