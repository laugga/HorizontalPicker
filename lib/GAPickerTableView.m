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

#define kSelectionAlignmentAnimationDuration 0.25

#pragma mark -
#pragma mark Initialization

#if !__has_feature(objc_arc)
- (void)dealloc
{
    //[_panGestureRecognizer release];
    [_scrollView release];
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
        
//        // Interaction
//        _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(userDidPan:)];
//        [self addGestureRecognizer:_panGestureRecognizer];
        
        // View
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
        
        // Layout
        _columnSize = CGSizeMake(60, self.frame.size.height);
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
                if(_numberOfColumns > 0)
                    _selectedColumn = 0;
                
                for(int column=0; column<_numberOfColumns; ++column)
                {
                    NSString * title = [_delegate pickerTableView:self titleForColumn:column forComponent:_component];
                    UILabel * label = [[UILabel alloc] init];
                    label.textColor = [UIColor whiteColor];
                    label.text = title;
                    label.textAlignment = UITextAlignmentCenter;
                    label.frame = CGRectMake(offset.x, offset.y, _columnSize.width, _columnSize.height);
                    [_columns addObject:label];
                    
                    [_scrollView addSubview:label];
                    
                    offset.x += _columnSize.width;
                    _contentSize += _columnSize.width;
                }
                
                // content size
                _scrollView.contentSize = CGSizeMake(_contentSize+_contentSizePadding, _columnSize.width);
                
                // Recalculate
                _minimumTranslation = -_numberOfColumns*_columnSize.width+_selectionEdgeInset;
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

//    NSNumber * layerTranslation = @(currentTranslation);
//    for(UILabel * column in _columns)
//    {
//        [column.layer setValue:layerTranslation forKeyPath:@"transform.translation.x"];
//    }
}

- (void)setSelectedColumn:(NSInteger)column animated:(BOOL)animated
{
    Log(@"setSelectedColumn: %d", column);
    
    // Range is [0, numberOfColumns]
    if(column > -1 && column < _numberOfColumns)
    {
        _selectedColumn = column;
        _contentOffset = _selectedColumn*_columnSize.width;
        
        [_scrollView setContentOffset:CGPointMake(-_selectionEdgeInset+_contentOffset, 0) animated:animated];
//
//        NSNumber * layerTranslation = @(_absoluteTranslation);
//
//        if(animated)
//        {
//            [UIView animateWithDuration:0.3 animations:^{
//                
//                NSInteger columnIndex=0;
//                for(UILabel * column in _columns)
//                {
//                    [column.layer setValue:layerTranslation forKeyPath:@"transform.translation.x"];
//                    
//                    if(columnIndex == _selectedColumn)
//                        column.layer.opacity = kSelectedColumnOpacity;
//                    else
//                        column.layer.opacity = kColumnOpacity;
//                    
//                    ++columnIndex;
//                }
//                
//            } completion:^(BOOL finished){
//                [[GAPickerTableInputSound sharedPickerTableInputSound] play]; // FIXME
//                
//            }];
//        }
//        else
//        {
//            NSInteger columnIndex=0;
//            for(UILabel * column in _columns)
//            {
//                [column.layer setValue:layerTranslation forKeyPath:@"transform.translation.x"];
//                
//                if(columnIndex == _selectedColumn)
//                    column.layer.opacity = kSelectedColumnOpacity;
//                else
//                    column.layer.opacity = kColumnOpacity;
//                
//                ++columnIndex;
//            }
//        }
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
            _selectionEdgeInset = 0.0;
            _contentSizePadding = _scrollView.frame.size.width-_columnSize.width;
            
        }
            break;
        case GAPickerSelectionAlignmentRight:
        {
            _selectionEdgeInset = self.frame.size.width-_columnSize.width;
            _contentSizePadding = 0.0;
        }
            break;
        case GAPickerSelectionAlignmentCenter:
        default:
        {
            _selectionEdgeInset = self.frame.size.width/2.0f-_columnSize.width/2.0;
            _contentSizePadding = _selectionEdgeInset;
        }
            break;
    }
    
    // Recalculate and correct non-integer values
    _selectionEdgeInset = floorf(_selectionEdgeInset);
    _contentSizePadding = floorf(_contentSizePadding);
    
    if(animated)
    {
        [UIView animateWithDuration:kSelectionAlignmentAnimationDuration animations:^{
            
            // Update scroll view
            _scrollView.contentInset = UIEdgeInsetsMake(0, _selectionEdgeInset, 0, 0);
            _scrollView.contentSize = CGSizeMake(_contentSize+_contentSizePadding, _columnSize.width);
            
        } completion:^(BOOL finished){
            
            // Update selected column
            [self setSelectedColumn:_selectedColumn animated:animated];
            
        }];
    }
    else
    {
        // Update scroll view
        _scrollView.contentInset = UIEdgeInsetsMake(0, _selectionEdgeInset, 0, 0);
        _scrollView.contentSize = CGSizeMake(_contentSize+_contentSizePadding, _columnSize.width);
        
        // Update selected column
        [self setSelectedColumn:_selectedColumn animated:animated];
    }
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
                CGFloat columnOffset = (columnTranslation + _selectionEdgeInset);
                
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

            [self setSelectedColumn:selectedColumn animated:YES];
            if(_delegate && [_delegate respondsToSelector:@selector(pickerTableView:didSelectColumn:inComponent:)]) // TODO when animation finishes
                [_delegate pickerTableView:self didSelectColumn:_selectedColumn inComponent:_component];
            
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

#pragma mark -
#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    PrettyLog;
    
    NSInteger selectedColumn = (NSInteger)((scrollView.contentOffset.x+_selectionEdgeInset+_columnSize.width/2.0)/_columnSize.width); // TODO optimize calculations with pre-calculated values
    
    if(selectedColumn > -1 && selectedColumn < _numberOfColumns)
    {
        if(selectedColumn != _selectedColumn && selectedColumn)
        {
            UILabel * previousSelectedColumn = [_columns objectAtIndex:_selectedColumn];
            UILabel * nextSelectedColumn = [_columns objectAtIndex:selectedColumn];
            _selectedColumn = selectedColumn;
            
            previousSelectedColumn.layer.opacity = kColumnOpacity;
            nextSelectedColumn.layer.opacity = kSelectedColumnOpacity;
        }
        
        Log(@"selectedColumn %d", selectedColumn);
    }

}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    PrettyLog;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    PrettyLog;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    PrettyLog;
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    PrettyLog;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    PrettyLog;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    PrettyLog;
}

@end
