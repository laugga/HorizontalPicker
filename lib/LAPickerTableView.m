/*
 
 LAPickerTableView.m
 LAPickerView
 
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

#import "LAPickerTableView.h"
#import "LAPickerViewLabel.h"

#import "LAPickerScrollView.h"

@implementation LAPickerTableView

@synthesize selectedColumn=_selectedColumn;

@synthesize dataSource=_dataSource;
@synthesize delegate=_delegate;

#define kHiddenColumnOpacity 0.0
#define kShownColumnOpacity 0.5
#define kSelectedColumnOpacity 1.0

#define kSelectionAlignmentAnimationDuration 0.25
#define kHiddenColumnsAnimationDuration 0.07

#pragma mark -
#pragma mark Initialization

#if !__has_feature(objc_arc)
- (void)dealloc
{
    if(_columns)
        [_columns release];
    
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
        _selectedColumnView = nil;
        _hiddenColumns = YES;
        _highlightedColumn = -1; // none highlighted, default
        
        // View
        _scrollView = [[LAPickerScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
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
        [self reloadData];
    }
}

- (void)updateScrollViewAnimated:(BOOL)animated
{
    PrettyLog;
    
    if(_numberOfColumns > 0)
    {
        if(animated)
        {
            [UIView animateWithDuration:kSelectionAlignmentAnimationDuration animations:^{
                
                // Update scroll view
                _scrollView.contentInset = UIEdgeInsetsMake(0, _selectionEdgeInset, 0, 0);
                _scrollView.contentSize = CGSizeMake(_contentSize+_contentSizePadding, CGRectGetHeight(self.bounds));
                
            } completion:^(BOOL finished){
                
                // Update selected column
                [self setSelectedColumn:_selectedColumn animated:animated];
                
            }];
        }
        else
        {
            // Update scroll view
            _scrollView.contentInset = UIEdgeInsetsMake(0, _selectionEdgeInset, 0, 0);
            _scrollView.contentSize = CGSizeMake(_contentSize+_contentSizePadding, CGRectGetHeight(self.bounds));
            
            // Update selected column
            [self setSelectedColumn:_selectedColumn animated:animated];
        }
    }
}

- (void)setSelectedColumn:(NSInteger)column animated:(BOOL)animated
{
    Log(@"setSelectedColumn: %d", column);
    
    if(_numberOfColumns && _selectedColumn != column)
    {
        // Range is [0, numberOfColumns]
        if(column > -1 && column < _numberOfColumns)
        {
            _contentOffset = [_columnsOffset[column] floatValue];
            CGPoint selectedColumnContentOffset = CGPointMake(-_firstColumnOffset+_contentOffset+_interColumnSpacing, 0);
            
            _selectedColumn = column;
            _selectedColumnView = _columns[_selectedColumn];
            
            if (animated)
            {
                [self hideColumns:NO animated:animated];
                [_scrollView setContentOffset:selectedColumnContentOffset animated:animated];
            }
            else {
                _scrollView.contentOffset = selectedColumnContentOffset;
            }
        }
    }
}

- (void)setSelectedColumnHighlighted:(BOOL)highlighted animated:(BOOL)animated;
{
    if(_selectedColumn > -1 && _selectedColumn < _numberOfColumns)
    {
        LAPickerViewLabel * view = (LAPickerViewLabel *)_columns[_selectedColumn];
        if ([view isKindOfClass:[LAPickerViewLabel class]])
        {
            [view setHighlighted:highlighted animated:YES];
        }
    }
}

- (void)setSelectionAlignment:(LAPickerSelectionAlignment)selectionAlignment
{
    [self setSelectionAlignment:selectionAlignment animated:NO];
}

- (void)setSelectionAlignment:(LAPickerSelectionAlignment)selectionAlignment animated:(BOOL)animated
{
    // Assign
    _selectionAlignment = selectionAlignment;
    
    if (self.dataSource)
    {
        CGFloat firstColumnWidth = 0.0f;
        if ([_columnsOffset count]) {
            firstColumnWidth = [_columnsOffset[0] doubleValue];
        }
        // Update layout
        switch (_selectionAlignment)
        {
            case LAPickerSelectionAlignmentLeft:
            {
                _selectionEdgeInset = 0.0f;
                _firstColumnOffset = 0.0f;
                _contentSizePadding = _scrollView.frame.size.width - firstColumnWidth;
                
            }
                break;
            case LAPickerSelectionAlignmentRight:
            {
                _selectionEdgeInset = self.frame.size.width - firstColumnWidth;
                _firstColumnOffset = self.frame.size.width;
                _contentSizePadding = 0.0f;
            }
                break;
            case LAPickerSelectionAlignmentCenter:
            default:
            {
                _selectionEdgeInset = self.frame.size.width/2.0f - firstColumnWidth/2.0f;
                _firstColumnOffset = self.frame.size.width/2.0f;
                _contentSizePadding = _selectionEdgeInset;
            }
                break;
        }
        
        // Recalculate and correct non-integer values
        _selectionEdgeInset = floorf(_selectionEdgeInset);
        _contentSizePadding = floorf(_contentSizePadding);
        _selectionOffsetDelta = _selectionEdgeInset + firstColumnWidth/2.0f;
        
        // Update scroll view
        [self updateScrollViewAnimated:animated];
    }
}

- (void)setHighlightedColumn:(NSInteger)highlightedColumn
{
    PrettyLog;
    
    // Range is [0, _numberOfColumns-1]
    highlightedColumn = MIN(highlightedColumn, _maxSelectionRange);
    highlightedColumn = MAX(0, highlightedColumn);
    
    // Selected column is different
    if(highlightedColumn != _highlightedColumn)
    {
        if(_highlightedColumn > -1) // Previous highlighted
        {
            UILabel * previousHighlightedColumn = [_columns objectAtIndex:_highlightedColumn];
            UILabel * nextHighlightedColumn = [_columns objectAtIndex:highlightedColumn];
            
            previousHighlightedColumn.layer.opacity = _hiddenColumns ? kHiddenColumnOpacity : kShownColumnOpacity;
            nextHighlightedColumn.layer.opacity = kSelectedColumnOpacity;
        }
        else // No previous selection
        {
            UILabel * nextHighlightedColumn = [_columns objectAtIndex:highlightedColumn];
            nextHighlightedColumn.layer.opacity = kSelectedColumnOpacity;
        }
        
        // Assign new value
        _highlightedColumn = highlightedColumn;
        
        // Notify delegate
        [_delegate pickerTableView:self didHighlightColumn:highlightedColumn inComponent:_component];
    }
}

- (UIView *)viewForColumn:(NSInteger)column
{
    UIView * view = nil;
    
    if(_numberOfColumns)
    {
        // Range is [0, numberOfColumns]
        if(column > -1 && column < _numberOfColumns)
        {
            view = [_columns objectAtIndex:column];
        }
    }
    
    return view;
}

#pragma mark -
#pragma mark Data

- (void)reloadData
{
    // Set number of columns to 0
    _numberOfColumns = 0;
    
    // Clean up
    [_columns removeAllObjects];
    [_scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_scrollView setContentSize:CGSizeZero];
    
    if(_dataSource)
    {
        _numberOfColumns = [_dataSource pickerTableView:self numberOfColumnsInComponent:_component];
        _columns = [[NSMutableArray alloc] initWithCapacity:_numberOfColumns];
        _columnsOffset = [[NSMutableArray alloc] initWithCapacity:_numberOfColumns];
        _maxSelectionRange = _numberOfColumns-1;
        
        _interColumnSpacing = 5.5f;

        if(_delegate)
        {
            CGSize columnSize = CGSizeZero;
            CGFloat cumulativeViewOffset = 0.0;
            
            for(int column=0; column<_numberOfColumns; ++column)
            {
                UIView * view = [[_delegate pickerTableView:self viewForColumn:column forComponent:_component reusingView:nil] retain];
                NSString * title = [_delegate pickerTableView:self titleForColumn:column forComponent:_component];
                
                if(view == nil)
                {
                    LAPickerViewLabel * label = [[LAPickerViewLabel alloc] init];
                    label.textColor = [UIColor blackColor];
                    label.text = title;
                    label.textAlignment = UITextAlignmentCenter;
                    label.backgroundColor = [UIColor clearColor];
                    
                    // TODO expose in the LAPickerView interface
                    label.highlightedFont = [UIFont boldSystemFontOfSize:20.0];
                    
                    [label sizeToFit];
                    
                    view = label;
                }
                else if(title != nil && [view isKindOfClass:[UILabel class]])
                {
                    [((UILabel *)view) setText:title];
                    [((UILabel *)view) sizeToFit];
                }
                
                columnSize.width = MAX(columnSize.width, view.frame.size.width);
                columnSize.height = MAX(columnSize.height, view.frame.size.height);
                
                CGFloat viewWidth = CGRectGetWidth(view.bounds);
                CGFloat viewHeight = CGRectGetHeight(view.bounds);
                
                view.frame = CGRectMake(cumulativeViewOffset, 0, viewWidth, viewHeight);
                
                cumulativeViewOffset += viewWidth + _interColumnSpacing;
                [_columnsOffset addObject:@(cumulativeViewOffset)];
                
                view.layer.opacity = kHiddenColumnOpacity;
                
                [_columns addObject:view];
                [_scrollView addSubview:view];
                
                //UIView * targetOffsetView = [[UIView alloc] initWithFrame:CGRectMake(cumulativeViewOffset, 0, 2, CGRectGetHeight(self.bounds))];
                //targetOffsetView.backgroundColor = [UIColor grayColor];
                //[_scrollView addSubview:targetOffsetView];
                
                _contentSize += (viewWidth + _interColumnSpacing);
            }
            
            // content size
            _scrollView.contentSize = CGSizeMake(_contentSize+_contentSizePadding, CGRectGetHeight(self.bounds));
        
            _selectedColumn = 0;
            _selectedColumnView = _columns[_selectedColumn];
            
            [self setSelectionAlignment:_selectionAlignment animated:NO];
        }
    }
}

- (NSInteger)columnForContentOffset:(CGFloat)contentOffset
{
    CGFloat targetOffset = contentOffset + _firstColumnOffset;
    CGFloat currentDelta = INFINITY;
    NSInteger currentColumn = 0;

    for (NSUInteger column=0; column<_numberOfColumns; ++column)
    {
        NSNumber * columnOffset = _columnsOffset[column];
        
        CGFloat delta = fabsf(columnOffset.floatValue - targetOffset);
        if (delta <= currentDelta) {
            currentDelta = delta;
            currentColumn = column;
        } else {
            break;
        }
    }
    
    return currentColumn;
}

#pragma mark -
#pragma mark Show/Hide with Animation

- (void)hideColumns:(BOOL)hiddenColumns animated:(BOOL)animated
{
    PrettyLog;
    NSLog(@"Selected column %d %@", _selectedColumn, _selectedColumnView);
    
    if (hiddenColumns == _hiddenColumns) {
        return;
    }
    
    if (!hiddenColumns && !(_isTouched || _scrollView.isDragging)) {
        return;
    }
    
    _hiddenColumns = hiddenColumns;
    
    CGFloat opacity = hiddenColumns ? kHiddenColumnOpacity : kShownColumnOpacity;
    
    if (animated) {
        [UIView beginAnimations:@"hideColumns" context:nil];
        [UIView setAnimationDuration:kHiddenColumnsAnimationDuration];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    }
    
    for (UIView * column in _columns) {
        
        // Skip selected column
        if (column == _selectedColumnView) {
            column.layer.opacity = 1.0;
            continue;
        }
        
        column.layer.opacity = opacity;
    }
    
    if (animated) {
        [UIView commitAnimations];
    }
}

#pragma mark -
#pragma mark LAPickerScrollViewDelegate

- (BOOL)doesTouchHitSelectedColumn:(UITouch *)touch
{
    UIView * selectedColumnView = [self viewForColumn:_selectedColumn];
    
    CGPoint touchLocation = [touch locationInView:self];
    CGRect touchHitArea = CGRectMake(CGRectGetWidth(self.frame)-CGRectGetWidth(selectedColumnView.frame)-30, 0, CGRectGetWidth(selectedColumnView.frame)+60, CGRectGetHeight(selectedColumnView.frame));
    
    return CGRectContainsPoint(touchHitArea, touchLocation);
}

- (void)scrollViewTouchesDidBegin:(UIScrollView *)scrollView withTouch:(UITouch *)touch
{
    PrettyLog;
    
    _isTouched = YES;
    
    if ([self doesTouchHitSelectedColumn:touch]) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self hideColumns:NO animated:YES];
        });
        
    } else {
        
        // Empty touch up
    }
}

- (void)scrollViewTouchesDidEnd:(UIScrollView *)scrollView withTouch:(UITouch *)touch
{
    PrettyLog;
    
    _isTouched = NO;
    
    if (!scrollView.isDecelerating && !scrollView.isDragging) {
        [self hideColumns:YES animated:YES];
        
        if ([self doesTouchHitSelectedColumn:touch]) {
            
            // Column touch up
            if(_delegate && [_delegate respondsToSelector:@selector(pickerTableView:didTouchUpColumn:inComponent:)])
                [_delegate pickerTableView:self didTouchUpColumn:_selectedColumn inComponent:_component];
            
        } else {
            
            // Empty touch up
            if(_delegate && [_delegate respondsToSelector:@selector(pickerTableView:didTouchUp:inComponent:)])
                [_delegate pickerTableView:self didTouchUp:touch inComponent:_component];
        }
    }
}

#pragma mark -
#pragma mark UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    PrettyLog;
    
    [self hideColumns:NO animated:NO];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // Ignore if empty
    if(_numberOfColumns > 0)
    {
        // Calculate highlighted column
        NSInteger highlightedColumn = [self columnForContentOffset:scrollView.contentOffset.x];
        
        // Change highlighted column
        [self setHighlightedColumn:highlightedColumn];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    PrettyLog;

    // Ignore if empty
    if(_numberOfColumns > 0)
    {
        CGFloat targetOffset = targetContentOffset->x + _firstColumnOffset;
 
        CGFloat currentOffset = 0.0f;
        CGFloat currentDelta = INFINITY;
        
        for (NSNumber * columnOffset in _columnsOffset)
        {
            CGFloat delta = fabsf(columnOffset.floatValue - targetOffset);
            if (delta <= currentDelta) {
                currentDelta = delta;
                currentOffset = columnOffset.floatValue;
            } else {
                break;
            }
        }
        
        // Change targetContentOffset
        targetContentOffset->x = currentOffset - _firstColumnOffset + _interColumnSpacing;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    PrettyLog;
    
    if (!decelerate) {
        [self hideColumns:YES animated:YES];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    PrettyLog;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    PrettyLog;
    
    // Calculate selected column
    NSInteger selectedColumn = [self columnForContentOffset:scrollView.contentOffset.x];
    
    // Range is [0, _numberOfColumns-1]
    selectedColumn = MIN(selectedColumn, _maxSelectionRange);
    selectedColumn = MAX(0, selectedColumn);
    
    if(selectedColumn != _selectedColumn)
    {
        if(selectedColumn > -1 && selectedColumn < _numberOfColumns)
        {
            // Assign new value
            _selectedColumn = selectedColumn;
            _selectedColumnView = _columns[_selectedColumn];
            
            // Notify delegate
            if(_delegate && [_delegate respondsToSelector:@selector(pickerTableView:didSelectColumn:inComponent:)])
                [_delegate pickerTableView:self didSelectColumn:_selectedColumn inComponent:_component];
        }
    }

    [self hideColumns:YES animated:YES];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    PrettyLog;
    
    [self hideColumns:YES animated:YES];
}

@end
