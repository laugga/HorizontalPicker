/*
 
 GAPickerTableView.h
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

#import <UIKit/UIKit.h>

#import "GAPickerTableViewDataSource.h"
#import "GAPickerTableViewDelegate.h"

/*!
 @abstract Options for the picker selection alignment, in relation to the view.
 
 @constant GAPickerSelectionAlignmentLeft
 Align selection along the left edge of the view.
 
 @constant GAPickerSelectionAlignmentCenter
 Align selection equally along both sides of the view. This is the default selection.
 
 @constant APickerSelectionAlignmentRight
 Align selection along the right edge of the view.
 */
typedef enum {
    GAPickerSelectionAlignmentLeft,
    GAPickerSelectionAlignmentCenter,
    GAPickerSelectionAlignmentRight
} GAPickerSelectionAlignment;

@interface GAPickerTableView : UIView <UIScrollViewDelegate>
{
    // State
    NSInteger _component;
    NSInteger _numberOfColumns;
    NSInteger _selectedColumn;
    
    // Data
    NSMutableArray * _columns;
    
    // Interaction
    UIPanGestureRecognizer * _panGestureRecognizer;
    BOOL _isScrolling;
    CGFloat _scrollingTranslation;
    
    // View
    UIScrollView * _scrollView;

    // Layout
    CGFloat _absoluteTranslation;
    CGFloat _minimumTranslation;
    CGFloat _maximumTranslation;
    CGSize _columnSize; // max-width found
    
    // Selection
    GAPickerSelectionAlignment _selectionAlignment;
    CGFloat _selectionEdgeInset; // inset from left edge
    CGFloat _contentSize; // content size for the columns
    CGFloat _contentSizePadding; // padding for the content size
    CGFloat _contentOffset;
    
    id<GAPickerTableViewDataSource> _dataSource;
    id<GAPickerTableViewDelegate> _delegate;
}

@property (nonatomic, readonly) NSInteger selectedColumn;

/*!
 Sets the selection to the left edge, center or right edge
 */
@property (nonatomic) GAPickerSelectionAlignment selectionAlignment;

@property (nonatomic, assign) id<GAPickerTableViewDataSource> dataSource;
@property (nonatomic, assign) id<GAPickerTableViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame andComponent:(NSInteger)component;

- (void)setSelectionAlignment:(GAPickerSelectionAlignment)selectionAlignment animated:(BOOL)animated;
- (void)setSelectedColumn:(NSInteger)column animated:(BOOL)animated;

@end
