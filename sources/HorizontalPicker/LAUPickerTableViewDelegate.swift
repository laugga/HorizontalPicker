/*

 LAUPickerTableViewDelegate.swift
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

/// Provides the content of one component's columns and is told when the column
/// under the selection indicator changes.
///
/// Every method other than `pickerTableView(_:didHighlightColumn:inComponent:)`
/// has a default implementation, so a delegate only writes the ones it needs.
public protocol LAUPickerTableViewDelegate: AnyObject {

    /// Called while scrolling, every time a different column passes under the
    /// selection indicator. This is what the input sound and haptic hang off.
    func pickerTableView(_ pickerTableView: LAUPickerTableView, didHighlightColumn column: Int, inComponent component: Int)

    /// Returns the title for a column, or `nil` to leave the column blank.
    func pickerTableView(_ pickerTableView: LAUPickerTableView, titleForColumn column: Int, forComponent component: Int) -> String?

    /// Returns the view for a column, or `nil` to let the table build its own
    /// label from the title.
    func pickerTableView(_ pickerTableView: LAUPickerTableView, viewForColumn column: Int, forComponent component: Int, reusingView view: UIView?) -> UIView?

    func pickerTableView(_ pickerTableView: LAUPickerTableView, willSelectColumnInComponent component: Int)

    func pickerTableView(_ pickerTableView: LAUPickerTableView, didChangeColumn column: Int, inComponent component: Int)

    func pickerTableView(_ pickerTableView: LAUPickerTableView, didTouchUpColumn column: Int, inComponent component: Int)

    func pickerTableView(_ pickerTableView: LAUPickerTableView, didTouchUp touch: UITouch, inComponent component: Int)

    /// Whether the unselected columns are hidden while the component is at rest.
    /// Defaults to `true`.
    func pickerTableView(_ pickerTableView: LAUPickerTableView, shouldHideUnselectedColumnsInComponent component: Int) -> Bool
}

public extension LAUPickerTableViewDelegate {

    func pickerTableView(_ pickerTableView: LAUPickerTableView, titleForColumn column: Int, forComponent component: Int) -> String? {
        return nil
    }

    func pickerTableView(_ pickerTableView: LAUPickerTableView, viewForColumn column: Int, forComponent component: Int, reusingView view: UIView?) -> UIView? {
        return nil
    }

    func pickerTableView(_ pickerTableView: LAUPickerTableView, willSelectColumnInComponent component: Int) {}

    func pickerTableView(_ pickerTableView: LAUPickerTableView, didChangeColumn column: Int, inComponent component: Int) {}

    func pickerTableView(_ pickerTableView: LAUPickerTableView, didTouchUpColumn column: Int, inComponent component: Int) {}

    func pickerTableView(_ pickerTableView: LAUPickerTableView, didTouchUp touch: UITouch, inComponent component: Int) {}

    func pickerTableView(_ pickerTableView: LAUPickerTableView, shouldHideUnselectedColumnsInComponent component: Int) -> Bool {
        return true
    }
}
