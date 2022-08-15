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

@class LAUPickerView;

@protocol LAUPickerViewDelegate <NSObject>
@optional

/*!
 returns width of column and height of row for each component.
 */
//- (CGFloat)pickerView:(LAUPickerView *)pickerView widthForComponent:(NSInteger)component;
- (CGFloat)pickerView:(LAUPickerView *)pickerView heightForComponent:(NSInteger)component;
- (CGFloat)pickerView:(LAUPickerView *)pickerView topSpaceForComponent:(NSInteger)component;

/*!
 these methods return either a plain NSString, a NSAttributedString, or a view (e.g UILabel) to display the row for the component.
 for the view versions, we cache any hidden and thus unused views and pass them back for reuse.
 If you return back a different object, the old one will be released. the view will be centered in the row rect
 */
- (NSString *)pickerView:(LAUPickerView *)pickerView titleForColumn:(NSInteger)column forComponent:(NSInteger)component;
- (UIView *)pickerView:(LAUPickerView *)pickerView viewForColumn:(NSInteger)column forComponent:(NSInteger)component reusingView:(UIView *)view;

/*!
 Called by the picker view when the user selects a column in a component.
 @param pickerView An object representing the picker view requesting the data.
 @param columm A zero-indexed number identifying a column of component. Columns are numbered left-to-right.
 @param component A zero-indexed number identifying a component of pickerView. Components are numbered top-to-bottom.
 @discussion
 To determine what value the user selected, the delegate uses the column index to access the value at the corresponding position in the array used to construct the component.
 */
- (void)pickerView:(LAUPickerView *)pickerView didChangeColumn:(NSInteger)column inComponent:(NSInteger)component;
- (void)pickerView:(LAUPickerView *)pickerView didTouchUpColumn:(NSInteger)column inComponent:(NSInteger)component;
- (void)pickerView:(LAUPickerView *)pickerView didTouchUp:(UITouch *)touch inComponent:(NSInteger)component;

@end
