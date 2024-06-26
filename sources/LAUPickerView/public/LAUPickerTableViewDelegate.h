/*
 
 LAUPickerViewDelegate.h
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

#import <Foundation/Foundation.h>

@class LAUPickerTableView;

@protocol LAUPickerTableViewDelegate <NSObject>

@required

- (void)pickerTableView:(LAUPickerTableView *)pickerView didHighlightColumn:(NSInteger)column inComponent:(NSInteger)component;

@optional

- (NSString *)pickerTableView:(LAUPickerTableView *)pickerTableView titleForColumn:(NSInteger)column forComponent:(NSInteger)component;
- (UIView *)pickerTableView:(LAUPickerTableView *)pickerTableView viewForColumn:(NSInteger)column forComponent:(NSInteger)component reusingView:(UIView *)view;

- (void)pickerTableView:(LAUPickerTableView *)pickerView willSelectColumnInComponent:(NSInteger)component;
- (void)pickerTableView:(LAUPickerTableView *)pickerView didChangeColumn:(NSInteger)column inComponent:(NSInteger)component;
- (void)pickerTableView:(LAUPickerTableView *)pickerView didTouchUpColumn:(NSInteger)column inComponent:(NSInteger)component;
- (void)pickerTableView:(LAUPickerTableView *)pickerView didTouchUp:(UITouch *)touch inComponent:(NSInteger)component;

- (BOOL)pickerTableView:(LAUPickerTableView *)pickerView shouldHideUnselectedColumnsInComponent:(NSInteger)component;

@end
