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
        
        // View
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
        
        // Layout
        _columnSize = CGSizeMake(60, frame.size.height);
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
        _numberOfColumns = 0;
        
        if(_dataSource)
        {
            _numberOfColumns = [_dataSource pickerTableView:self numberOfColumnsInComponent:_component];
            _columns = [[NSMutableArray alloc] initWithCapacity:_numberOfColumns];
            _maxSelectionRange = _numberOfColumns-1;
            
            if(_delegate)
            {
                for(int column=0; column<_numberOfColumns; ++column)
                {
                    NSString * title = [_delegate pickerTableView:self titleForColumn:column forComponent:_component];
                    UILabel * label = [[UILabel alloc] init];
                    label.textColor = [UIColor whiteColor];
                    label.text = title;
                    label.textAlignment = UITextAlignmentCenter;
                    label.frame = CGRectMake(_contentSize, 0, _columnSize.width, _columnSize.height);
                    label.layer.opacity = kColumnOpacity;
                    [_columns addObject:label];
                    [_scrollView addSubview:label];
                    
                    _contentSize += _columnSize.width;
                }
                
                // content size
                _scrollView.contentSize = CGSizeMake(_contentSize+_contentSizePadding, _columnSize.height);
            }
            
            // Update selected column
            [self updateScrollViewAnimated:NO];
            [self setSelectedColumn:0 animated:NO];
        }
    }
}

- (void)updateScrollViewAnimated:(BOOL)animated
{
    if(_numberOfColumns > 0)
    {
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
}

- (void)setSelectedColumn:(NSInteger)column animated:(BOOL)animated
{
    Log(@"setSelectedColumn: %d", column);
    
    if(_numberOfColumns)
    {
        // Range is [0, numberOfColumns]
        if(column > -1 && column < _numberOfColumns)
        {
            _contentOffset = column*_columnSize.width;
            
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
    _selectionOffsetDelta = _selectionEdgeInset + _columnSize.width/2.0;
    
    // Update scroll view
    [self updateScrollViewAnimated:animated];
}

#pragma mark -
#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        // Ignore if empty
        if(_numberOfColumns > 0)
        {
            // Calculate selected column
            NSInteger selectedColumn = (NSInteger)((scrollView.contentOffset.x+_selectionOffsetDelta)/_columnSize.width); // TODO optimize calculations with pre-calculated values
            
            // Range is [0, _numberOfColumns-1]
            selectedColumn = MIN(selectedColumn, _maxSelectionRange);
            selectedColumn = MAX(0, selectedColumn);

            // Selected column is different
            if(selectedColumn != _selectedColumn)
            {
                if(_selectedColumn > -1) // Previous selection
                {
                    UILabel * previousSelectedColumn = [_columns objectAtIndex:_selectedColumn];
                    UILabel * nextSelectedColumn = [_columns objectAtIndex:selectedColumn];
                    
                    previousSelectedColumn.layer.opacity = kColumnOpacity;
                    nextSelectedColumn.layer.opacity = kSelectedColumnOpacity;
                    
                    [[GAPickerTableInputSound sharedPickerTableInputSound] play]; // Play sound when selected column changes
                }
                else // No previous selection
                {
                    UILabel * nextSelectedColumn = [_columns objectAtIndex:selectedColumn];
                    nextSelectedColumn.layer.opacity = kSelectedColumnOpacity;
                }
                
                _selectedColumn = selectedColumn;
            }
        }
    });
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
    
    if(decelerate == NO)
    {
        NSInteger selectedColumn = (NSInteger)((scrollView.contentOffset.x+_selectionEdgeInset+_columnSize.width/2.0)/_columnSize.width); // TODO optimize calculations with pre-calculated values
        
        if(selectedColumn > -1 && selectedColumn < _numberOfColumns)
        {
            [self setSelectedColumn:selectedColumn animated:YES];
        }
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    PrettyLog;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    PrettyLog;
    
    NSInteger selectedColumn = (NSInteger)((scrollView.contentOffset.x+_selectionEdgeInset+_columnSize.width/2.0)/_columnSize.width); // TODO optimize calculations with pre-calculated values
    
    if(selectedColumn > -1 && selectedColumn < _numberOfColumns)
    {
        [self setSelectedColumn:selectedColumn animated:YES];
        
        if(_delegate && [_delegate respondsToSelector:@selector(pickerTableView:didSelectColumn:inComponent:)]) // TODO when animation finishes
            [_delegate pickerTableView:self didSelectColumn:_selectedColumn inComponent:_component];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    PrettyLog;
    
    NSInteger selectedColumn = (NSInteger)((scrollView.contentOffset.x+_selectionEdgeInset+_columnSize.width/2.0)/_columnSize.width); // TODO optimize calculations with pre-calculated values
    
    if(selectedColumn > -1 && selectedColumn < _numberOfColumns)
    {
        [self setSelectedColumn:selectedColumn animated:YES];
        
        if(_delegate && [_delegate respondsToSelector:@selector(pickerTableView:didSelectColumn:inComponent:)]) // TODO when animation finishes
            [_delegate pickerTableView:self didSelectColumn:_selectedColumn inComponent:_component];
    }
}

@end
