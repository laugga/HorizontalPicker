/*
 
 GAPickerView.h
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

#import "GAPickerViewDataSource.h"
#import "GAPickerViewDelegate.h"

#import "GAPickerTableView.h"

//@class <UIPickerViewDataSource>, UIImageView, NSMutableArray, UIView, <UIPickerViewDelegate>, CALayer, UIColor;

@interface GAPickerView : UIView <UIInputViewAudioFeedback, GAPickerTableViewDataSource, GAPickerTableViewDelegate/*UIPickerTableViewContainerDelegate, UITableViewDelegate, NSCoding, UITableViewDataSource,*/>
{
    NSMutableArray * _tables;
//    UIView *_topFrame;
//    NSMutableArray *_dividers;
//    NSMutableArray *_selectionBars;
//    UIView *_backgroundView;
    NSInteger _numberOfComponents;
//    UIImageView *_topGradient;
//    UIImageView *_bottomGradient;
//    UIView *_foregroundView;
//    CALayer *_maskGradientLayer;
//    UIView *_topLineView;
//    UIView *_bottomLineView;
//    struct {
//        unsigned int needsLayout : 1;
//        unsigned int delegateRespondsToNumberOfComponentsInPickerView : 1;
//        unsigned int delegateRespondsToNumberOfRowsInComponent : 1;
//        unsigned int delegateRespondsToDidSelectRow : 1;
//        unsigned int delegateRespondsToViewForRow : 1;
//        unsigned int delegateRespondsToTitleForRow : 1;
//        unsigned int delegateRespondsToAttributedTitleForRow : 1;
//        unsigned int delegateRespondsToWidthForComponent : 1;
//        unsigned int delegateRespondsToRowHeightForComponent : 1;
//        unsigned int showsSelectionBar : 1;
//        unsigned int allowsMultipleSelection : 1;
//        unsigned int allowSelectingCells : 1;
//        unsigned int soundsDisabled : 1;
//        unsigned int usesCheckedSelection : 1;
//        unsigned int skipsBackground : 1;
//    } _pickerViewFlags;
//    BOOL _usesModernStyle;
//    UIColor *_textColor;
//    UIColor *_textShadowColor;
//    BOOL _isInLayoutSubviews;
//    BOOL _magnifierEnabled;
    
    id<GAPickerViewDataSource> _dataSource;
    id<GAPickerViewDelegate> _delegate;
}

@property (nonatomic, readonly) BOOL enableInputClicksWhenVisible;

@property (nonatomic, assign) id<GAPickerViewDataSource> dataSource;
@property (nonatomic, assign) id<GAPickerViewDelegate> delegate;

- (NSInteger)selectedColumnInComponent:(NSInteger)component;

- (void)selectColumn:(NSInteger)column inComponent:(NSInteger)component animated:(BOOL)animated;

//@property BOOL showsSelectionIndicator;
//@property(readonly) int numberOfComponents;
//@property(setter=_setMagnifierEnabled:) BOOL _magnifierEnabled;
//@property(getter=_usesModernStyle,setter=_setUsesModernStyle:) BOOL usesModernStyle;
//@property(getter=_highlightColor,setter=_setHighlightColor:,retain) UIColor * highlightColor;
//@property(getter=_textColor,setter=_setTextColor:,retain) UIColor * textColor;
//@property(getter=_textShadowColor,setter=_setTextShadowColor:,retain) UIColor * textShadowColor;
//@property(setter=_setInLayoutSubviews:) BOOL _isInLayoutSubviews;
//
//+ (id)_modernNonCenterCellFont;
//+ (id)_modernCenterCellFont;
//+ (struct CGSize { float x1; float x2; })sizeForCurrentOrientationThatFits:(struct CGSize { float x1; float x2; })arg1;
//+ (struct CGSize { float x1; float x2; })defaultSizeForCurrentOrientation;
//+ (struct CGSize { float x1; float x2; })sizeThatFits:(struct CGSize { float x1; float x2; })arg1 forInterfaceOrientation:(int)arg2;
//
//- (void)reload;
//- (void)setBackgroundColor:(id)arg1;
//- (id)initWithFrame:(struct CGRect { struct CGPoint { float x_1_1_1; float x_1_1_2; } x1; struct CGSize { float x_2_1_1; float x_2_1_2; } x2; })arg1;
//- (void)setFrame:(struct CGRect { struct CGPoint { float x_1_1_1; float x_1_1_2; } x1; struct CGSize { float x_2_1_1; float x_2_1_2; } x2; })arg1;
//- (void)setHidden:(BOOL)arg1;
//- (id)_contentView;
//- (void)setDataSource:(id)arg1;
//- (void)setNeedsLayout;
//- (void)setBounds:(struct CGRect { struct CGPoint { float x_1_1_1; float x_1_1_2; } x1; struct CGSize { float x_2_1_1; float x_2_1_2; } x2; })arg1;
//- (id)dataSource;
//- (int)numberOfColumns;
//- (id)init;
//- (void)setDelegate:(id)arg1;
//- (void)dealloc;
//- (id)delegate;
//- (BOOL)isAccessibilityElementByDefault;
//- (void)_setInLayoutSubviews:(BOOL)arg1;
//- (BOOL)_isInLayoutSubviews;
//- (void)_setTextShadowColor:(id)arg1;
//- (id)_textShadowColor;
//- (void)_setHighlightColor:(id)arg1;
//- (id)_highlightColor;
//- (void)_setUsesModernStyle:(BOOL)arg1;
//- (void)_setMagnifierEnabled:(BOOL)arg1;
//- (struct CGRect { struct CGPoint { float x_1_1_1; float x_1_1_2; } x1; struct CGSize { float x_2_1_1; float x_2_1_2; } x2; })_effectiveTableViewFrameForColumn:(int)arg1;
//- (int)selectedRowForColumn:(int)arg1;
//- (struct _NSRange { unsigned int x1; unsigned int x2; })visibleRowsForColumn:(int)arg1;
//- (void)_setDrawsBackground:(BOOL)arg1;
//- (BOOL)_usesCheckedSelection;
//- (void)_setUsesCheckedSelection:(BOOL)arg1;
//- (BOOL)allowsMultipleSelection;
//- (BOOL)showsSelectionIndicator;
//- (void)setShowsSelectionIndicator:(BOOL)arg1;
//- (void)reloadAllPickerPieces;
//- (id)viewForRow:(int)arg1 forComponent:(int)arg2;
//- (int)numberOfRowsInColumn:(int)arg1;
//- (struct CGSize { float x1; float x2; })rowSizeForComponent:(int)arg1;
//- (double)scrollAnimationDuration;
//- (struct CGSize { float x1; float x2; })sizeThatFits:(struct CGSize { float x1; float x2; })arg1;
//- (BOOL)_contentHuggingDefault_isUsuallyFixedWidth;
//- (BOOL)_contentHuggingDefault_isUsuallyFixedHeight;
//- (void)reloadDataForColumn:(int)arg1;
//- (void)setSoundsEnabled:(BOOL)arg1;
//- (id)tableView:(id)arg1 cellForRowAtIndexPath:(id)arg2;
//- (int)tableView:(id)arg1 numberOfRowsInSection:(int)arg2;
//- (BOOL)_usesCheckSelection;
//- (BOOL)_soundsEnabled;
//- (void)_sendCheckedRow:(int)arg1 inTableView:(id)arg2 checked:(BOOL)arg3;
//- (id)_delegateTitleForRow:(int)arg1 forComponent:(int)arg2;
//- (id)_delegateAttributedTitleForRow:(int)arg1 forComponent:(int)arg2;
//- (id)_textColor;
//- (void)selectRow:(int)arg1 inComponent:(int)arg2 animated:(BOOL)arg3;
//- (void)_selectRow:(int)arg1 inComponent:(int)arg2 animated:(BOOL)arg3 notify:(BOOL)arg4;
//- (void)_sendSelectionChangedFromTable:(id)arg1;
//- (void)_sendSelectionChangedForComponent:(int)arg1;
//- (int)selectedRowInComponent:(int)arg1;
//- (void)_updateWithOldSize:(struct CGSize { float x1; float x2; })arg1 newSize:(struct CGSize { float x1; float x2; })arg2;
//- (struct CGSize { float x1; float x2; })_sizeThatFits:(struct CGSize { float x1; float x2; })arg1;
//- (int)_delegateNumberOfRowsInComponent:(int)arg1;
//- (void)_resetSelectionOfTables;
//- (void)_addMagnifierLinesForRowHeight:(float)arg1;
//- (BOOL)_magnifierEnabled;
//- (struct CGRect { struct CGPoint { float x_1_1_1; float x_1_1_2; } x1; struct CGSize { float x_2_1_1; float x_2_1_2; } x2; })_selectionBarRectForHeight:(float)arg1;
//- (void)setAllowsMultipleSelection:(BOOL)arg1;
//- (id)_createTableWithFrame:(struct CGRect { struct CGPoint { float x_1_1_1; float x_1_1_2; } x1; struct CGSize { float x_2_1_1; float x_2_1_2; } x2; })arg1 forComponent:(int)arg2;
//- (id)_createColumnWithTableFrame:(struct CGRect { struct CGPoint { float x_1_1_1; float x_1_1_2; } x1; struct CGSize { float x_2_1_1; float x_2_1_2; } x2; })arg1 rowHeight:(float)arg2;
//- (id)createDividerWithFrame:(struct CGRect { struct CGPoint { float x_1_1_1; float x_1_1_2; } x1; struct CGSize { float x_2_1_1; float x_2_1_2; } x2; })arg1;
//- (BOOL)_usesModernStyle;
//- (float)_wheelShift;
//- (float)_delegateWidthForComponent:(int)arg1 ofCount:(int)arg2 withSizeLeft:(float)arg3;
//- (id)_createViewForPickerPiece:(int)arg1;
//- (BOOL)_drawsBackground;
//- (int)numberOfComponents;
//- (int)numberOfRowsInComponent:(int)arg1;
//- (id)tableViewForColumn:(int)arg1;
//- (void)layoutSubviews;
//- (float)_delegateRowHeightForComponent:(int)arg1;
//- (void)_setTextColor:(id)arg1;
//- (struct CATransform3D { float x1; float x2; float x3; float x4; float x5; float x6; float x7; float x8; float x9; float x10; float x11; float x12; float x13; float x14; float x15; float x16; })_perspectiveTransform;
//- (float)_tableRowHeight;
//- (int)columnForTableView:(id)arg1;
//- (struct CGSize { float x1; float x2; })_intrinsicSizeWithinSize:(struct CGSize { float x1; float x2; })arg1;
//- (struct CGSize { float x1; float x2; })defaultSize;
//- (id)imageForPickerPiece:(int)arg1;
//- (id)_popoverSuffix;
//- (id)_selectionBarSuffix;
//- (void)reloadComponent:(int)arg1;
//- (void)reloadData;
//- (int)_delegateNumberOfComponents;
//- (void)reloadAllComponents;
//- (void)didMoveToWindow;
//- (void)setAlpha:(float)arg1;
//- (void)_updateSound;
//- (id)hitTest:(struct CGPoint { float x1; float x2; })arg1 withEvent:(id)arg2;
//- (void)_populateArchivedSubviews:(id)arg1;
//- (BOOL)_shouldDrawWithModernStyle;
//- (BOOL)_isLandscapeOrientation;
//- (id)_orientationImageSuffix;
//- (id)pickerImageNamePrefix;
//- (id)initWithCoder:(id)arg1;
//- (void)encodeWithCoder:(id)arg1;

@end