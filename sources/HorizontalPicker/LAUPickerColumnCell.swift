/*

 LAUPickerColumnCell.swift
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

/// The cell one column is drawn in.
///
/// A column is either a title, which the cell draws with a label of its own and
/// recycles along with the cell, or a view the delegate supplied, which the cell
/// hosts as it was handed over.
final class LAUPickerColumnCell: UICollectionViewCell {

    static let reuseIdentifier = "LAUPickerColumnCell"

    /// The font a title is drawn in, and the bolder one it grows into while the
    /// column is highlighted.
    static let titleFont = UIFont.systemFont(ofSize: UIFont.labelFontSize)
    // TODO expose in the LAUPickerView interface
    static let highlightedTitleFont = UIFont.boldSystemFont(ofSize: 20.0)

    /// The width a title takes at its natural size. The layout places the column
    /// against this, so it has to be measured with the font the label draws in.
    static func width(forTitle title: String) -> CGFloat {
        return title.size(withAttributes: [.font: titleFont]).width.rounded(.up)
    }

    /// The view drawn for this column, whichever of the two it is.
    private(set) var hostedView: UIView?

    private var titleLabel: LAUPickerViewLabel?

    /// The column's opacity: hidden, shown or selected. Held on the drawn view
    /// rather than the cell, so it survives the cell being recycled only as long
    /// as the column it stands for does.
    var columnOpacity: Float {
        get {
            return hostedView?.layer.opacity ?? 0.0
        }
        set {
            hostedView?.layer.opacity = newValue
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        if let hostedView = hostedView, hostedView !== titleLabel {
            hostedView.removeFromSuperview()
        }

        hostedView = nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // The column keeps its natural size and sits at the head of the cell,
        // which is exactly as wide as the column itself.
        hostedView?.frame.origin = .zero
    }

    /// Draws a title, in the cell's own label.
    func showTitle(_ title: String, highlighted: Bool) {
        let label = titleLabel ?? makeTitleLabel()

        // `highlightedFont` measures the scale between the two fonts against the
        // title, and takes the font in place as the one to come back to — so the
        // label has to be plain, and the text has to be set, before it is given.
        label.setHighlighted(false, animated: false)
        label.font = LAUPickerColumnCell.titleFont
        label.text = title
        label.highlightedFont = LAUPickerColumnCell.highlightedTitleFont
        label.sizeToFit()
        label.setHighlighted(highlighted, animated: false)
        label.isHidden = false

        hostedView = label
        setNeedsLayout()
    }

    /// Draws a view the delegate supplied.
    func showView(_ view: UIView) {
        titleLabel?.isHidden = true

        guard view !== hostedView else {
            return
        }

        view.removeFromSuperview()
        contentView.addSubview(view)

        hostedView = view
        setNeedsLayout()
    }

    /// Grows the column into its highlighted font, if it is one of the cell's
    /// own labels — a view the delegate supplied is left as it is.
    func setColumnHighlighted(_ highlighted: Bool, animated: Bool) {
        (hostedView as? LAUPickerViewLabel)?.setHighlighted(highlighted, animated: animated)
    }

    private func makeTitleLabel() -> LAUPickerViewLabel {
        let label = LAUPickerViewLabel()
        label.textColor = .black
        label.textAlignment = .center
        label.backgroundColor = .clear

        contentView.addSubview(label)
        titleLabel = label

        return label
    }
}
