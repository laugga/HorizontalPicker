/*
 
 LAUPickerTableView.h
 LAUPickerView
 
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

#import <UIKit/UIKit.h>

#import "LAUPickerTableViewDataSource.h"
#import "LAUPickerTableViewDelegate.h"

#import "LAUPickerScrollView.h"

/*!
 @abstract Options for the picker selection alignment, in relation to the view.
 
 @constant LAUPickerSelectionAlignmentLeft
 Align selection along the left edge of the view.
 
 @constant LAUPickerSelectionAlignmentCenter
 Align selection equally along both sides of the view. This is the default selection.
 
 @constant APickerSelectionAlignmentRight
 Align selection along the right edge of the view.
 */
typedef enum {
    LAUPickerSelectionAlignmentLeft,
    LAUPickerSelectionAlignmentCenter,
    LAUPickerSelectionAlignmentRight
} LAUPickerSelectionAlignment;

@interface LAUPickerTableView : UIView <UIScrollViewDelegate, LAUPickerScrollViewDelegate>
{
    // Columns
    NSInteger _component;
    NSInteger _numberOfColumns;

    // Selection
    NSInteger _selectedColumn;
    NSInteger _highlightedColumn;
    NSInteger _maxSelectionRange; // [0, _numberOfColumns-1]
    UIView * _selectedColumnView;

    // State
    BOOL _hiddenColumns;
    BOOL _isTouched;
    
    // Subviews
    LAUPickerScrollView * _scrollView;
    NSMutableArray * _columns;
    NSMutableArray * _columnsOffset;
    
    // Layout
    LAUPickerSelectionAlignment _selectionAlignment;
    CGFloat _interColumnSpacing;
    CGFloat _selectionEdgeInset; // inset from left edge
    CGFloat _firstColumnOffset;
    CGFloat _selectionOffsetDelta; // _selectionEdgeInset + _columnSize.width/2.0
    CGFloat _contentSize; // content size for the columns
    CGFloat _contentSizePadding; // padding for the content size
    CGFloat _contentOffset;
    
    __unsafe_unretained id<LAUPickerTableViewDataSource> _dataSource;
    __unsafe_unretained id<LAUPickerTableViewDelegate> _delegate;
}

@property (nonatomic, readonly) NSInteger selectedColumn;

/*!
 Sets the selection to the left edge, center or right edge
 */
@property (nonatomic) LAUPickerSelectionAlignment selectionAlignment;

@property (nonatomic, assign) id<LAUPickerTableViewDataSource> dataSource;
@property (nonatomic, assign) id<LAUPickerTableViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame andComponent:(NSInteger)component;

- (void)setSelectionAlignment:(LAUPickerSelectionAlignment)selectionAlignment animated:(BOOL)animated;
- (void)setSelectedColumn:(NSInteger)column animated:(BOOL)animated;

- (void)setSelectedColumnHighlighted:(BOOL)highlighted animated:(BOOL)animated;

- (void)hideColumns:(BOOL)hiddenColumns animated:(BOOL)animated;
- (UIView *)viewForColumn:(NSInteger)column;

/*!
 Reloads all columns in table view;
 */
- (void)reloadData;

@end
