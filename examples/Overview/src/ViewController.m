/*
 
 ViewController.m
 LAUPickerViewOverview
 
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

#import "ViewController.h"

#import "Constants.h"

@interface ViewController ()

@end

@implementation ViewController

#pragma mark -
#pragma mark Initialization

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self)
    {
        
    }
    return self;
}

- (void)dealloc
{
    [_horizontalPickerView release];
    [_verticalPickerView release];
    [super dealloc];
}

#pragma mark -
#pragma mark View

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"LAUPickerView Overview";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Toggle Sounds" style:UIBarButtonItemStylePlain target:self action:@selector(togglePickerViewSoundsEnabled)];
    
    self.view.autoresizesSubviews = YES;
    
    _horizontalPickerView = [[LAUPickerView alloc] initWithFrame:CGRectMake(0, 80, self.view.frame.size.width, self.view.frame.size.height/3)];
    _horizontalPickerView.selectionAlignment = LAUPickerSelectionAlignmentCenter;
    _horizontalPickerView.dataSource = self;
    _horizontalPickerView.delegate = self;
    
    _horizontalPickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    
    [self.view addSubview:_horizontalPickerView];
    
    _verticalPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height/2, self.view.frame.size.width, self.view.frame.size.height/2)];
    _verticalPickerView.dataSource = self;
    _verticalPickerView.delegate = self;
    
    _verticalPickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin;
    
    [self.view addSubview:_verticalPickerView];
    
//    double delayInSeconds = 5.0;
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//        _horizontalPickerView.selectionAlignment = LAUPickerSelectionAlignmentLeft;
//    });
//    
//    delayInSeconds = 10.0;
//    popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//        _horizontalPickerView.selectionAlignment = LAUPickerSelectionAlignmentRight;
//    });
//    
//    delayInSeconds = 15.0;
//    popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//        _horizontalPickerView.selectionAlignment = LAUPickerSelectionAlignmentCenter;
//    });
//    
//    delayInSeconds = 20.0;
//    popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//        [_horizontalPickerView setSelectionAlignment:LAUPickerSelectionAlignmentLeft animated:YES];
//    });
//    
//    delayInSeconds = 25.0;
//    popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//        [_horizontalPickerView setSelectionAlignment:LAUPickerSelectionAlignmentRight animated:YES];
//    });
//    
//    delayInSeconds = 30.0;
//    popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//        [_horizontalPickerView setSelectionAlignment:LAUPickerSelectionAlignmentCenter animated:YES];
//    });
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    PrettyLog;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    PrettyLog;
}

#pragma mark -
#pragma mark Actions

- (void)togglePickerViewSoundsEnabled
{
    [_horizontalPickerView setSoundsEnabled:!(_horizontalPickerView.soundsEnabled)];
}

#pragma mark -
#pragma mark LAUPickerViewDataSource and UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return kLAUPickerViewOverviewNumberOfComponents;
}

- (NSInteger)pickerView:(LAUPickerView *)pickerView numberOfColumnsInComponent:(NSInteger)component
{
    switch (component)
    {
        case 0: // aperture
            return aperturesCount;
            break;
        case 1: // shutter speed
            return shutterSpeedsCount;
            break;
        case 2: // iso speed
            return isoSpeedsCount;
            break;
        default:
            return 0;
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (component)
    {
        case 0: // aperture
            return aperturesCount;
            break;
        case 1: // shutter speed
            return shutterSpeedsCount;
            break;
        case 2: // iso speed
            return isoSpeedsCount;
            break;
        default:
            return 0;
    }
}

#pragma mark -
#pragma mark LAUPickerViewDelegate and UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForColumn:(NSInteger)column forComponent:(NSInteger)component
{
    switch (component) {
        case 0: // aperture
            return [NSString stringWithFormat:@"f/%.1f", apertures[column]];
            break;
        case 1: // shutter speed
            return [NSString stringWithFormat:@"1/%.1f", shutterSpeeds[column]];
            break;
        case 2: // iso speed
            return [NSString stringWithFormat:@"%.0f", isoSpeeds[column]];
            break;
        default:
            return @"";
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    switch (component) {
        case 0: // aperture
            return [NSString stringWithFormat:@"f/%.1f", apertures[row]];
            break;
        case 1: // shutter speed
            return [NSString stringWithFormat:@"1/%.1f", shutterSpeeds[row]];
            break;
        case 2: // iso speed
            return [NSString stringWithFormat:@"%.0f", isoSpeeds[row]];
            break;
        default:
            return @"";
    }
}

- (UIView *)pickerView:(LAUPickerView *)pickerView viewForColumn:(NSInteger)column forComponent:(NSInteger)component
{
    UIView * viewForColumn = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    viewForColumn.backgroundColor = [UIColor grayColor];
    
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = UITextAlignmentCenter;
    label.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:30.0f];
    label.text = [self pickerView:pickerView titleForColumn:column forComponent:component];
    
    [viewForColumn addSubview:label];

    return viewForColumn;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    Log(@"pickerView: vertical didSelectRow: %d inComponent: %d", row, component);
    
    [_horizontalPickerView selectColumn:row inComponent:component animated:YES];
}

- (void)pickerView:(LAUPickerView *)pickerView didSelectColumn:(NSInteger)column inComponent:(NSInteger)component
{
    Log(@"pickerView: horizontal didSelectColumn: %d/%d inComponent: %d", column, [pickerView selectedColumnInComponent:component], component);
    
    [_verticalPickerView selectRow:column inComponent:component animated:YES];
}

@end
