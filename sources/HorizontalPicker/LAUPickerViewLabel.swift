//
//  LAUPickerViewLabel.swift
//  HorizontalPicker
//
//  Created by Luis Laugga on 15.09.15.
//

import UIKit

/// The default column view: a label that scales into a bolder font when the
/// column it stands for becomes the highlighted one.
@objc(LAUPickerViewLabel)
public class LAUPickerViewLabel: UILabel {

    /// The font the label takes while highlighted. Set it after the text, so the
    /// scale between the two fonts can be measured against the title.
    @objc public var highlightedFont: UIFont? {
        didSet {
            defaultFont = font
            updateHighlightTransforms()
        }
    }

    private var defaultFont: UIFont?
    private var toHighlightedTransform: CGAffineTransform = .identity
    private var fromHighlightedTransform: CGAffineTransform = .identity

    public override func layoutSubviews() {
        super.layoutSubviews()

        var frame = self.frame
        frame.size = (text ?? "").size(withAttributes: [.font: font as Any])
        self.frame = frame
    }

    private func updateHighlightTransforms() {
        guard let highlightedFont = highlightedFont else {
            toHighlightedTransform = .identity
            fromHighlightedTransform = .identity
            return
        }

        let text = self.text ?? ""
        let size = text.size(withAttributes: [.font: font as Any])
        let highlightedSize = text.size(withAttributes: [.font: highlightedFont])

        // An empty title has no width to scale from; leaving the transforms at
        // identity keeps the arithmetic below out of NaN.
        guard size.width > 0 else {
            toHighlightedTransform = .identity
            fromHighlightedTransform = .identity
            return
        }

        let scale = highlightedSize.width / size.width
        let translation = ((highlightedSize.width - size.width) / 2.0).rounded(.down)

        toHighlightedTransform = CGAffineTransform(scaleX: scale, y: scale)
            .translatedBy(x: translation, y: 0)
        fromHighlightedTransform = CGAffineTransform(scaleX: 1.0 / scale, y: 1.0 / scale)
            .translatedBy(x: -translation, y: 0)
    }

    public override var isHighlighted: Bool {
        get {
            return super.isHighlighted
        }
        set {
            setHighlighted(newValue, animated: false)
        }
    }

    @objc(setHighlighted:animated:)
    public func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.isHighlighted = highlighted

        // Unanimated has to land at once rather than in an animation completion:
        // a column's cell is recycled, and the label it holds has to be back in
        // a known font before the next title is measured against it.
        guard animated else {
            transform = .identity
            font = highlighted ? highlightedFont : defaultFont
            return
        }

        UIView.animate(withDuration: 0.15, animations: {
            self.transform = highlighted ? self.toHighlightedTransform : self.fromHighlightedTransform
        }, completion: { _ in
            self.font = highlighted ? self.highlightedFont : self.defaultFont
            self.transform = .identity
        })
    }
}
