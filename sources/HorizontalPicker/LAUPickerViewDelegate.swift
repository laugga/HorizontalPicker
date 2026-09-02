/*

 LAUPickerViewDelegate.swift
 HorizontalPicker

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

import UIKit

/// Provides the content for each component's column, either as a string or as a
/// view, and is told about new selections.
///
/// Every method is optional; the picker falls back to the same defaults the
/// Objective-C implementation used when the delegate did not respond to a
/// selector.
@objc public protocol LAUPickerViewDelegate: NSObjectProtocol {

    @objc(pickerView:accessibilityIdentifierForComponent:)
    optional func pickerView(_ pickerView: LAUPickerView, accessibilityIdentifierForComponent component: Int) -> String

    /// Returns the height of the given component. Defaults to an equal share of
    /// the picker view's height.
    @objc(pickerView:heightForComponent:)
    optional func pickerView(_ pickerView: LAUPickerView, heightForComponent component: Int) -> CGFloat

    /// Returns the vertical offset of the given component. Defaults to the
    /// components being stacked top to bottom.
    @objc(pickerView:topSpaceForComponent:)
    optional func pickerView(_ pickerView: LAUPickerView, topSpaceForComponent component: Int) -> CGFloat

    /// Returns the title to display for a column-component pair.
    @objc(pickerView:titleForColumn:forComponent:)
    optional func pickerView(_ pickerView: LAUPickerView, titleForColumn column: Int, forComponent component: Int) -> String

    /// Returns the view to display for a column-component pair. Takes precedence
    /// over the title.
    @objc(pickerView:viewForColumn:forComponent:reusingView:)
    optional func pickerView(_ pickerView: LAUPickerView, viewForColumn column: Int, forComponent component: Int, reusingView view: UIView?) -> UIView

    /// Called when a new, different column has been selected in a component.
    @objc(pickerView:didChangeColumn:inComponent:)
    optional func pickerView(_ pickerView: LAUPickerView, didChangeColumn column: Int, inComponent component: Int)

    /// Called when a touch ends on the selected column of a component.
    @objc(pickerView:didTouchUpColumn:inComponent:)
    optional func pickerView(_ pickerView: LAUPickerView, didTouchUpColumn column: Int, inComponent component: Int)

    /// Called when a touch ends anywhere else in a component.
    @objc(pickerView:didTouchUp:inComponent:)
    optional func pickerView(_ pickerView: LAUPickerView, didTouchUp touch: UITouch, inComponent component: Int)
}
