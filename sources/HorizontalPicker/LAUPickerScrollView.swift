//
//  LAUPickerScrollView.swift
//  HorizontalPicker
//
//  Created by Luis Laugga on 12/5/15.
//

import UIKit

/// Reports raw touch begin/end to the scroll view delegate.
///
/// `UIScrollView` drives scrolling through gesture recognizers, so the picker
/// table needs the touches themselves to tell a tap on the selected column from
/// a tap on empty space.
@objc public protocol LAUPickerScrollViewDelegate: UIScrollViewDelegate {

    @objc(scrollViewTouchesDidBegin:withTouch:)
    optional func scrollViewTouchesDidBegin(_ scrollView: UIScrollView, withTouch touch: UITouch)

    @objc(scrollViewTouchesDidEnd:withTouch:)
    optional func scrollViewTouchesDidEnd(_ scrollView: UIScrollView, withTouch touch: UITouch)
}

@objc(LAUPickerScrollView)
public class LAUPickerScrollView: UIScrollView {

    private var pickerDelegate: LAUPickerScrollViewDelegate? {
        return delegate as? LAUPickerScrollViewDelegate
    }

    // The touches are only forwarded, never passed to super: scrolling itself is
    // handled by the pan gesture recognizer, and the picker table needs to see
    // every touch to tell a tap on the selected column from a tap on empty space.

    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard touches.count == 1, let touch = touches.first else {
            return // ignore
        }

        pickerDelegate?.scrollViewTouchesDidBegin?(self, withTouch: touch)
    }

    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard touches.count == 1, let touch = touches.first else {
            return // ignore
        }

        pickerDelegate?.scrollViewTouchesDidEnd?(self, withTouch: touch)
    }

    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard touches.count == 1, let touch = touches.first else {
            return // ignore
        }

        pickerDelegate?.scrollViewTouchesDidEnd?(self, withTouch: touch)
    }
}
