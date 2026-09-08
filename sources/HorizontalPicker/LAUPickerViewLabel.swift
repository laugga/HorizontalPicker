//
//  LAUPickerViewLabel.swift
//  HorizontalPicker
//
//  Created by Luis Laugga on 15.09.15.
//

import UIKit

/// The default column view: a label kept at exactly the size of the text it
/// draws, which is the width the layout places its column against.
public class LAUPickerViewLabel: UILabel {

    public override func layoutSubviews() {
        super.layoutSubviews()

        var frame = self.frame
        frame.size = (text ?? "").size(withAttributes: [.font: font as Any])
        self.frame = frame
    }
}
