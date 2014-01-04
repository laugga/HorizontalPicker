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

#import "GAPickerTableInputSound.h"

@implementation GAPickerTableView

@synthesize selectedColumn=_selectedColumn;

@synthesize dataSource=_dataSource;
@synthesize delegate=_delegate;

#define kColumnOpacity 0.35
#define kSelectedColumnOpacity 1.0


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
        // State
        _component = component;
        _selectedColumn = -1; // none selected, default
        
        // Interaction
        _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(userDidPan:)];
        [self addGestureRecognizer:_panGestureRecognizer];
        
        // Layout
        _columnRect = CGRectMake(0, 0, 60, self.frame.size.height);
        _translationVelocity = 0.0f;
    }
    return self;
}

#pragma mark -
#pragma mark Drawing

- (void)drawRect:(CGRect)rect
{
    PrettyLog;
    
    if(_translationVelocity != 0.0)
    {
        Log(@"velocity %f", _translationVelocity);
        _absoluteTranslation += _translationVelocity;
        _translationVelocity *= 0.9;
        [self updateLayoutSubviews];
//        if(_translationVelocity < 1.0 || _translationVelocity > -1.0)
//           _translationVelocity = 0.0;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setNeedsDisplay];
        });
    }
    
    [super drawRect:rect];
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
                if(_numberOfColumns > 0)
                    _selectedColumn = 0;
                
                for(int column=0; column<_numberOfColumns; ++column)
                {
                    NSString * title = [_delegate pickerTableView:self titleForColumn:column forComponent:_component];
                    UILabel * label = [[UILabel alloc] init];
                    label.textColor = [UIColor whiteColor];
                    label.text = title;
                    label.textAlignment = UITextAlignmentCenter;
                    label.frame = CGRectMake(offset.x, offset.y, _columnRect.size.width, _columnRect.size.height);
                    [_columns addObject:label];
                    
                    [self addSubview:label];
                    
                    offset.x += _columnRect.size.width;
                }
                
                // Recalculate
                _minimumTranslation = -_numberOfColumns*_columnRect.size.width+_selectionTranslation;
            }
            
            // Update
            [self setSelectedColumn:_selectedColumn animated:NO];
        }
    }
}

- (void)updateLayoutSubviews
{
    CGFloat currentTranslation = _absoluteTranslation + _scrollingTranslation;
    
    currentTranslation = MIN(currentTranslation, _maximumTranslation);
    currentTranslation = MAX(currentTranslation, _minimumTranslation);

    NSNumber * layerTranslation = @(currentTranslation);
    for(UILabel * column in _columns)
    {
        [column.layer setValue:layerTranslation forKeyPath:@"transform.translation.x"];
    }
}

- (void)setSelectedColumn:(NSInteger)column animated:(BOOL)animated
{
    Log(@"setSelectedColumn: %d", column);
    
    // Check if column is valid
    if(column >= 0 && column < _numberOfColumns)
    {
        _selectedColumn = column;
        _absoluteTranslation = _selectionTranslation-_selectedColumn*_columnRect.size.width;
        
        NSNumber * layerTranslation = @(_absoluteTranslation);

        if(animated)
        {
            [UIView animateWithDuration:0.3 animations:^{
                
                NSInteger columnIndex=0;
                for(UILabel * column in _columns)
                {
                    [column.layer setValue:layerTranslation forKeyPath:@"transform.translation.x"];
                    
                    if(columnIndex == _selectedColumn)
                        column.layer.opacity = kSelectedColumnOpacity;
                    else
                        column.layer.opacity = kColumnOpacity;
                    
                    ++columnIndex;
                }
                
            } completion:^(BOOL finished){
                [[GAPickerTableInputSound sharedPickerTableInputSound] play]; // FIXME
                
            }];
        }
        else
        {
            NSInteger columnIndex=0;
            for(UILabel * column in _columns)
            {
                [column.layer setValue:layerTranslation forKeyPath:@"transform.translation.x"];
                
                if(columnIndex == _selectedColumn)
                    column.layer.opacity = kSelectedColumnOpacity;
                else
                    column.layer.opacity = kColumnOpacity;
                
                ++columnIndex;
            }
        }
    }
}

- (void)setSelectionAlignment:(GAPickerSelectionAlignment)selectionAlignment
{
    [self setSelectionAlignment:selectionAlignment animated:NO];
}

- (void)setSelectionAlignment:(GAPickerSelectionAlignment)selectionAlignment animated:(BOOL)animated
{
    // Assign
    _selectionAlignment = selectionAlignment;
    
    // Update layout
    switch (_selectionAlignment)
    {
        case GAPickerSelectionAlignmentLeft:
        {
            _selectionTranslation = 0.0;
        }
            break;
        case GAPickerSelectionAlignmentRight:
        {
            _selectionTranslation = self.frame.size.width-_columnRect.size.width;
        }
            break;
        case GAPickerSelectionAlignmentCenter:
        default:
        {
            _selectionTranslation = self.frame.size.width/2.0f-_columnRect.size.width/2.0;
        }
            break;
    }
    
    // Recalculate and correct non-integer values
    _selectionTranslation = floorf(_selectionTranslation);
    _minimumTranslation = -_numberOfColumns*_columnRect.size.width+_selectionTranslation;
    _maximumTranslation = _selectionTranslation+_columnRect.size.width/2.0;
    
    // Update layout
    [self setSelectedColumn:_selectedColumn animated:animated];
}

#pragma mark -
#pragma mark Pan Gesture

- (void)userDidPan:(UIPanGestureRecognizer *)panGesture
{
    switch (panGesture.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            if(_delegate && [_delegate respondsToSelector:@selector(pickerTableView:willSelectColumnInComponent:)]) // TODO when animation finishes
                [_delegate pickerTableView:self willSelectColumnInComponent:_component];
            
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
            _absoluteTranslation = MIN(_absoluteTranslation, _maximumTranslation);
            _absoluteTranslation = MAX(_absoluteTranslation, _minimumTranslation);
            
            NSInteger columnIndex=0;
            NSInteger selectedColumn=-1;
            CGFloat selectedOffset = INFINITY;
            for(UILabel * column in _columns)
            {
                CGFloat columnTranslation = -column.frame.origin.x;
                CGFloat columnOffset = (columnTranslation + _selectionTranslation);
                
                if(fabs(columnOffset) < selectedOffset)
                {
                    selectedOffset = columnOffset;
                    selectedColumn = columnIndex;
                }
                else
                {
                    break; // TODO optimize
                }
                columnIndex+=1;
            }
            
            CGPoint velocity = [panGesture velocityInView:self];
            
            Log(@"velocity (%f,%f)", velocity.x, velocity.y);
            
            if(velocity.x > 5.0 || velocity.x < -5.0)
            {
                _translationVelocity = velocity.x*0.03;
                [self setNeedsDisplay];
            }
            else
            {
                [self setSelectedColumn:selectedColumn animated:YES];
                if(_delegate && [_delegate respondsToSelector:@selector(pickerTableView:didSelectColumn:inComponent:)]) // TODO when animation finishes
                    [_delegate pickerTableView:self didSelectColumn:_selectedColumn inComponent:_component];
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
