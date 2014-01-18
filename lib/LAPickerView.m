/*
 
 LAPickerView.h
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

#import "LAPickerView.h"

#import "LAPickerTableInputSound.h"

@implementation LAPickerView

@synthesize dataSource=_dataSource;
@synthesize delegate=_delegate;

@synthesize selectionAlignment=_selectionAlignment;
@dynamic soundsEnabled;

#pragma mark -
#pragma mark Initialization

#if !__has_feature(objc_arc)
- (void)dealloc
{
    [_tables release];
    [super dealloc];
}
#endif

- (id)initWithFrame:(struct CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        _tables = [[NSMutableArray alloc] init];
        _selectingTable = nil;
        
        _selectionAlignment = LAPickerSelectionAlignmentCenter; // default is center
        _pickerViewFlags.soundsEnabled = 1; // default is enabled	
    }
    return self;
}

#pragma mark -
#pragma mark Layout

- (void)layoutSubviews
{
    PrettyLog;

    if(_numberOfComponents == 0)
    {
        [self reloadData];
    }
}

- (void)setSelectionAlignment:(LAPickerSelectionAlignment)selectionAlignment
{
    // Assign
    _selectionAlignment = selectionAlignment;
    
    // Set to all tables
    for(LAPickerTableView * table in _tables)
        table.selectionAlignment = selectionAlignment;
}

- (void)setSelectionAlignment:(LAPickerSelectionAlignment)selectionAlignment animated:(BOOL)animated
{
    // Assign
    _selectionAlignment = selectionAlignment;
    
    // Set to all tables
    for(LAPickerTableView * table in _tables)
        [table setSelectionAlignment:selectionAlignment animated:animated];
}

#pragma mark -
#pragma mark Data

- (void)reloadData
{
    // Set number of components to 0
    _numberOfComponents = 0;
    
    // Clean up
    [_tables removeAllObjects];
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    if(_dataSource)
    {
        _numberOfComponents = [_dataSource numberOfComponentsInPickerView:self];
        
        CGFloat tableViewRectSizeWidth = self.frame.size.width;
        CGFloat tableViewRectSizeHeight = floorf(self.frame.size.height/_numberOfComponents);
        
        for(int component=0; component<_numberOfComponents; ++component)
        {
            CGRect tableViewRect = CGRectMake(0, component*tableViewRectSizeHeight, tableViewRectSizeWidth, tableViewRectSizeHeight);
            LAPickerTableView * tableView = [[LAPickerTableView alloc] initWithFrame:tableViewRect andComponent:component];
            tableView.dataSource = self;
            tableView.delegate = self;
            tableView.selectionAlignment = _selectionAlignment;
            [_tables addObject:tableView];
            [self addSubview:tableView];
            [tableView release];
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
        LAPickerTableView * pickerTableView = [_tables objectAtIndex:component];
        selectedColumnInComponent = pickerTableView.selectedColumn;
    }
    
    return selectedColumnInComponent;
}

- (void)selectColumn:(NSInteger)column inComponent:(NSInteger)component animated:(BOOL)animated
{
    if(component < [_tables count])
    {
        LAPickerTableView * pickerTableView = [_tables objectAtIndex:component];
        [pickerTableView setSelectedColumn:column animated:animated];
    }
}

#pragma mark -
#pragma mark Sounds

- (BOOL)soundsEnabled
{
    return (_pickerViewFlags.soundsEnabled == 1);
}

- (void)setSoundsEnabled:(BOOL)soundsEnabled
{
    _pickerViewFlags.soundsEnabled = (soundsEnabled ? 1 : 0);
}

#pragma mark -
#pragma mark LAPickerTableViewDataSource

- (NSInteger)pickerTableView:(LAPickerTableView *)pickerTableView numberOfColumnsInComponent:(NSInteger)component
{
    if(_dataSource)
    {
        return [_dataSource pickerView:self numberOfColumnsInComponent:component];
    }
    
    return 0;
}

#pragma mark -
#pragma mark LAPickerTableViewDelegate

- (void)pickerTableView:(LAPickerTableView *)pickerView didHighlightColumn:(NSInteger)column inComponent:(NSInteger)component
{
    if(_pickerViewFlags.soundsEnabled)
        [[LAPickerTableInputSound sharedPickerTableInputSound] play]; // Play sound when highlighted column changes
}

- (NSString *)pickerTableView:(LAPickerTableView *)pickerTableView titleForColumn:(NSInteger)column forComponent:(NSInteger)component
{
    if(_delegate && [_delegate respondsToSelector:@selector(pickerView:titleForColumn:forComponent:)])
    {
        return [_delegate pickerView:self titleForColumn:column forComponent:component];
    }
    
    return 0;
}

- (void)pickerTableView:(LAPickerTableView *)pickerTableView willSelectColumnInComponent:(NSInteger)component
{
    _selectingTable = pickerTableView;
}

- (void)pickerTableView:(LAPickerTableView *)pickerTableView didSelectColumn:(NSInteger)column inComponent:(NSInteger)component
{
    _selectingTable = nil;
    
    if(_delegate && [_delegate respondsToSelector:@selector(pickerView:didSelectColumn:inComponent:)])
    {
        return [_delegate pickerView:self didSelectColumn:column inComponent:component];
    }
}

@end