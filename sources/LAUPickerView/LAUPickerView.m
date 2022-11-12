/*
 
 LAUPickerView.h
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

#import "LAUPickerView.h"

#import "LAUPickerTableInputSound.h"

@implementation LAUPickerView

@synthesize dataSource=_dataSource;
@synthesize delegate=_delegate;

@synthesize selectionAlignment=_selectionAlignment;
@dynamic soundsEnabled;
@dynamic hapticsEnabled;

#pragma mark -
#pragma mark Initialization

#if !__has_feature(objc_arc)
- (void)dealloc
{
    [_tables release];
    [super dealloc];
}
#endif

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(struct CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        [self setup];
    }
    return self;
}

- (void)setup
{
    _tables = [[NSMutableArray alloc] init];
    _selectingTable = nil;
    
    _selectionAlignment = LAUPickerSelectionAlignmentCenter; // default is center
    
    // Haptic and Sound Feedback
    _pickerViewFlags.soundsEnabled = 1; // default is enabled
    _pickerViewFlags.hapticsEnabled = 1; // default is enabled
    _feedbackGenerator = [[UISelectionFeedbackGenerator alloc] init];
    [_feedbackGenerator prepare];
}

- (void)setDelegate:(id<LAUPickerViewDelegate>)delegate
{
    _delegate = delegate;

    if(_delegate && [_delegate respondsToSelector:@selector(pickerView:titleForColumn:forComponent:)])
        _pickerViewFlags.delegateRespondsToTitleForColumn = 1;
    
    if(_delegate && [_delegate respondsToSelector:@selector(pickerView:viewForColumn:forComponent:reusingView:)])
        _pickerViewFlags.delegateRespondsToViewForColumn = 1;
    
    if (_delegate && _dataSource) {
        [self reloadDataIfNeeded];
    }
}

- (void)setDataSource:(id<LAUPickerViewDataSource>)dataSource
{
    _dataSource = dataSource;

    if (_delegate && _dataSource) {
        [self reloadDataIfNeeded];
    }
}

#pragma mark -
#pragma mark Layout

- (void)setSelectionAlignment:(LAUPickerSelectionAlignment)selectionAlignment
{
    // Assign
    _selectionAlignment = selectionAlignment;
    
    // Set to all tables
    for(LAUPickerTableView * table in _tables)
        table.selectionAlignment = selectionAlignment;
}

- (void)setSelectionAlignment:(LAUPickerSelectionAlignment)selectionAlignment animated:(BOOL)animated
{
    // Assign
    _selectionAlignment = selectionAlignment;
    
    // Set to all tables
    for(LAUPickerTableView * table in _tables)
        [table setSelectionAlignment:selectionAlignment animated:animated];
}

#pragma mark -
#pragma mark Data

- (void)reloadDataIfNeeded
{
    if(_numberOfComponents == 0)
    {
        [self reloadData];
    }
}

- (void)reloadData
{
    // Set number of components to 0
    _numberOfComponents = 0;
    
    // Clean up
    [_tables removeAllObjects];
    for (UIView * view in self.subviews) {
        [view removeFromSuperview];
    }
    
    if(_dataSource && _delegate)
    {
        _numberOfComponents = [_dataSource numberOfComponentsInPickerView:self];
        
        CGFloat tableViewRectSizeWidth = self.frame.size.width;
        CGFloat tableViewRectSizeHeight = floorf(self.frame.size.height/_numberOfComponents);
        CGFloat tableViewRectSizeTop = 0;
        
        for(int component=0; component<_numberOfComponents; ++component)
        {
            if(_delegate && [_delegate respondsToSelector:@selector(pickerView:heightForComponent:)]) {
                tableViewRectSizeHeight = [_delegate pickerView:self heightForComponent:component];
            }
            
            if(_delegate && [_delegate respondsToSelector:@selector(pickerView:topSpaceForComponent:)]) {
                tableViewRectSizeTop = [_delegate pickerView:self topSpaceForComponent:component];
            } else {
                tableViewRectSizeTop = tableViewRectSizeHeight * (CGFloat)component;
            }
            
            CGRect tableViewRect = CGRectMake(0, tableViewRectSizeTop, tableViewRectSizeWidth, tableViewRectSizeHeight);
            LAUPickerTableView * tableView = [[LAUPickerTableView alloc] initWithFrame:tableViewRect andComponent:component];
            tableView.dataSource = self;
            tableView.delegate = self;
            tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            [tableView reloadData];
            [_tables addObject:tableView];
            [self addSubview:tableView];
            
            tableView.selectionAlignment = _selectionAlignment;
            
#if !__has_feature(objc_arc)
            [tableView release];
#endif
        }
    }
}

#pragma mark -
#pragma mark Selection

- (NSInteger)selectedColumnInComponent:(NSInteger)component
{
    NSInteger selectedColumnInComponent = -1;
    
    if(component < [_tables count])
    {
        LAUPickerTableView * pickerTableView = [_tables objectAtIndex:component];
        selectedColumnInComponent = pickerTableView.selectedColumn;
    }
    
    return selectedColumnInComponent;
}

- (void)selectColumn:(NSInteger)column inComponent:(NSInteger)component animated:(BOOL)animated
{
    if(component < [_tables count])
    {
        LAUPickerTableView * pickerTableView = [_tables objectAtIndex:component];
        [pickerTableView setSelectedColumn:column animated:animated];
    }
}

- (void)setSelectedColumnHighlighted:(BOOL)highlighted inComponent:(NSInteger)component animated:(BOOL)animated
{
    if(component < [_tables count])
    {
        LAUPickerTableView * pickerTableView = [_tables objectAtIndex:component];
        [pickerTableView setSelectedColumnHighlighted:highlighted animated:animated];
    }
}

#pragma mark -
#pragma mark Animation

- (void)showComponent:(NSInteger)shownComponent andHideComponent:(NSInteger)hiddenComponent animated:(BOOL)animated
{
    
    if (shownComponent < [_tables count] && hiddenComponent < [_tables count]) {
        LAUPickerTableView * shownPickerTableView = [_tables objectAtIndex:shownComponent];
        LAUPickerTableView * hiddenPickerTableView = [_tables objectAtIndex:hiddenComponent];
        
//        UIView * shownPickerTableViewColumn = [shownPickerTableView viewForColumn:shownPickerTableView.selectedColumn];
//        UIView * hiddenPickerTableViewColumn = [hiddenPickerTableView viewForColumn:hiddenPickerTableView.selectedColumn];
        
        double delayMilliseconds = 0.1;
        
        if (animated) {
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayMilliseconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                shownPickerTableView.alpha = 0.0;
                
                CGFloat shownAnimationScale = CGRectGetHeight(shownPickerTableView.frame) / CGRectGetHeight(hiddenPickerTableView.frame);
                CGFloat hiddenAnimationScale = 1.0 / shownAnimationScale;
                CGFloat hiddenAnimationTranslate = hiddenAnimationScale > 1.0 ? -50.0 : 70.0;
                CGFloat shownAnimationTranslate = shownAnimationScale > 1.0 ? 60.0 : 240.0;
                
                shownPickerTableView.transform = CGAffineTransformScale(CGAffineTransformIdentity, hiddenAnimationScale, hiddenAnimationScale);
                shownPickerTableView.transform = CGAffineTransformTranslate(shownPickerTableView.transform, hiddenAnimationTranslate, 0);
                
                [UIView animateWithDuration:0.3 delay:0.0 usingSpringWithDamping:1.0 initialSpringVelocity:0.0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut animations:^{
                    
                    shownPickerTableView.transform = CGAffineTransformIdentity;
                    shownPickerTableView.alpha = 1.0;
                    
                    hiddenPickerTableView.transform = CGAffineTransformScale(CGAffineTransformIdentity, shownAnimationScale/2.0, shownAnimationScale/2.0);
                    hiddenPickerTableView.transform = CGAffineTransformTranslate(hiddenPickerTableView.transform, shownAnimationTranslate, 0);
                    hiddenPickerTableView.alpha = 0.0;
                    
                } completion:^(BOOL finished) {
                    
                    hiddenPickerTableView.transform = CGAffineTransformIdentity;
                    
                    [shownPickerTableView hideColumns:YES animated:animated];
                    [hiddenPickerTableView hideColumns:YES animated:animated];
                }];
            });
            
        } else {
            shownPickerTableView.alpha = 1.0;
            hiddenPickerTableView.alpha = 0.0;
            
            [shownPickerTableView hideColumns:YES animated:animated];
            [hiddenPickerTableView hideColumns:YES animated:animated];
        }

    }
}

#pragma mark -
#pragma mark Sounds and Haptics

- (BOOL)soundsEnabled
{
    return (_pickerViewFlags.soundsEnabled == 1);
}

- (void)setSoundsEnabled:(BOOL)soundsEnabled
{
    _pickerViewFlags.soundsEnabled = (soundsEnabled ? 1 : 0);
}

- (BOOL)hapticsEnabled
{
    return (_pickerViewFlags.hapticsEnabled == 1);
}

- (void)setHapticsEnabled:(BOOL)hapticsEnabled
{
    _pickerViewFlags.hapticsEnabled = (hapticsEnabled ? 1 : 0);
}

#pragma mark -
#pragma mark LAUPickerTableViewDataSource

- (NSInteger)pickerTableView:(LAUPickerTableView *)pickerTableView numberOfColumnsInComponent:(NSInteger)component
{
    if(_dataSource)
    {
        return [_dataSource pickerView:self numberOfColumnsInComponent:component];
    }
    
    return 0;
}

#pragma mark -
#pragma mark LAUPickerTableViewDelegate

- (void)pickerTableView:(LAUPickerTableView *)pickerView didHighlightColumn:(NSInteger)column inComponent:(NSInteger)component
{
    if(_pickerViewFlags.soundsEnabled)
    {
        [[LAUPickerTableInputSound sharedPickerTableInputSound] play]; // Play sound when highlighted column changes
    }
    
    if(_pickerViewFlags.hapticsEnabled)
    {
        [_feedbackGenerator selectionChanged];
        [_feedbackGenerator prepare];
    }
}

- (NSString *)pickerTableView:(LAUPickerTableView *)pickerTableView titleForColumn:(NSInteger)column forComponent:(NSInteger)component
{
    if(_pickerViewFlags.delegateRespondsToTitleForColumn)
    {
        return [_delegate pickerView:self titleForColumn:column forComponent:component];
    }
    
    return nil;
}

- (UIView *)pickerTableView:(LAUPickerTableView *)pickerTableView viewForColumn:(NSInteger)column forComponent:(NSInteger)component reusingView:(UIView *)view
{
    if(_pickerViewFlags.delegateRespondsToViewForColumn)
    {
        return [_delegate pickerView:self viewForColumn:column forComponent:component reusingView:nil];
    }
    
    return nil;
}

- (void)pickerTableView:(LAUPickerTableView *)pickerTableView willSelectColumnInComponent:(NSInteger)component
{
    _selectingTable = pickerTableView;
}

- (void)pickerTableView:(LAUPickerTableView *)pickerTableView didChangeColumn:(NSInteger)column inComponent:(NSInteger)component
{
    _selectingTable = nil;
    
    if(_delegate && [_delegate respondsToSelector:@selector(pickerView:didChangeColumn:inComponent:)])
    {
        return [_delegate pickerView:self didChangeColumn:column inComponent:component];
    }
}

- (void)pickerTableView:(LAUPickerTableView *)pickerView didTouchUpColumn:(NSInteger)column inComponent:(NSInteger)component
{
    if(_delegate && [_delegate respondsToSelector:@selector(pickerView:didTouchUpColumn:inComponent:)])
    {
        return [_delegate pickerView:self didTouchUpColumn:column inComponent:component];
    }
}

- (void)pickerTableView:(LAUPickerTableView *)pickerView didTouchUp:(UITouch *)touch inComponent:(NSInteger)component
{
    if(_delegate && [_delegate respondsToSelector:@selector(pickerView:didTouchUp:inComponent:)])
    {
        return [_delegate pickerView:self didTouchUp:touch inComponent:component];
    }
}

@end
