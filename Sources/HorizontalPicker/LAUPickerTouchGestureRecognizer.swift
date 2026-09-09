/*

 LAUPickerTouchGestureRecognizer.swift
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

/// A press that reports the touch driving it.
///
/// The picker has to see a touch land and lift to tell a tap on the selected
/// column from a tap on empty space, and to reveal the other columns while a
/// finger rests on the control. A recognizer alongside the collection view's own
/// pan is enough for that, but its action carries no touch, and
/// `pickerTableView(_:didTouchUp:inComponent:)` hands the delegate one — so the
/// recognizer keeps hold of it.
///
/// `minimumPressDuration` of zero makes it begin as the finger lands and cancel
/// as soon as the finger travels far enough for the pan to take over, which is
/// the whole of the state the picker needs.
final class LAUPickerTouchGestureRecognizer: UILongPressGestureRecognizer {

    private(set) var currentTouch: UITouch?

    override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)

        minimumPressDuration = 0.0
        cancelsTouchesInView = false
        delaysTouchesBegan = false
        delaysTouchesEnded = false
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        currentTouch = touches.first

        super.touchesBegan(touches, with: event)
    }

    override func reset() {
        super.reset()

        currentTouch = nil
    }
}
