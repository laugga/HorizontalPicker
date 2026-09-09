/*

 LAUPickerColumnLayout.swift
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

/// Lays one component's columns out in a single horizontal line, and decides
/// where a drag comes to rest.
///
/// All of the picker's geometry lives here: the natural width of each column,
/// the spacing between them, the insets that let the first and last column
/// reach the selection indicator, and the content offset at which each column
/// rests under it. The snap is `targetContentOffset(forProposedContentOffset:
/// withScrollingVelocity:)` — UIKit asks the layout where a drag should end, so
/// nothing has to intercept `scrollViewWillEndDragging` to move it.
final class LAUPickerColumnLayout: UICollectionViewLayout {

    static let defaultInterColumnSpacing: CGFloat = 5.5

    /// The natural width of every column, in order.
    var columnWidths: [CGFloat] = [] {
        didSet {
            var origin: CGFloat = 0.0

            columnOrigins = columnWidths.map { width in
                defer { origin += width + interColumnSpacing }
                return origin
            }

            invalidateLayout()
        }
    }

    let interColumnSpacing: CGFloat = LAUPickerColumnLayout.defaultInterColumnSpacing

    /// Which edge of the component the selected column is aligned with.
    var selectionAlignment: LAUPickerSelectionAlignment = .center {
        didSet {
            guard selectionAlignment != oldValue else { return }
            invalidateLayout()
        }
    }

    /// The x of each column within the run of columns, before the leading inset.
    private var columnOrigins: [CGFloat] = []

    private var attributes: [UICollectionViewLayoutAttributes] = []
    private var contentSize: CGSize = .zero
    private var preparedViewportSize: CGSize = .zero

    private var viewportSize: CGSize {
        return collectionView?.bounds.size ?? .zero
    }

    // MARK: - Layout

    override func prepare() {
        super.prepare()

        preparedViewportSize = viewportSize

        attributes = columnWidths.indices.map { column in
            let attributes = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: column, section: 0))
            attributes.frame = frame(forColumn: column)
            return attributes
        }

        contentSize = CGSize(width: (attributes.last?.frame.maxX ?? 0.0) + trailingInset,
                             height: max(preparedViewportSize.height, 1.0))
    }

    override var collectionViewContentSize: CGSize {
        return contentSize
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attributes.filter { $0.frame.intersects(rect) }
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard attributes.indices.contains(indexPath.item) else {
            return nil
        }

        return attributes[indexPath.item]
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        // Scrolling moves the bounds origin and changes nothing; a resize moves
        // the insets, and with them every column.
        return newBounds.size != preparedViewportSize
    }

    /// The frame a column occupies, derived rather than looked up, so it can be
    /// asked for before the layout has been prepared.
    func frame(forColumn column: Int) -> CGRect {
        guard columnOrigins.indices.contains(column) else {
            return .zero
        }

        return CGRect(x: leadingInset + columnOrigins[column],
                      y: 0.0,
                      width: max(columnWidths[column], 1.0),
                      height: max(viewportSize.height, 1.0))
    }

    // MARK: - Selection

    /// The inset that lets the first column reach the selection indicator.
    private var leadingInset: CGFloat {
        guard let first = columnWidths.first else {
            return 0.0
        }

        switch selectionAlignment {
        case .left:
            return 0.0
        case .center:
            return max(0.0, ((viewportSize.width - first) / 2.0).rounded(.down))
        case .right:
            return max(0.0, (viewportSize.width - first).rounded(.down))
        }
    }

    /// The inset that lets the last column reach the selection indicator.
    private var trailingInset: CGFloat {
        guard let last = columnWidths.last else {
            return 0.0
        }

        switch selectionAlignment {
        case .left:
            return max(0.0, (viewportSize.width - last).rounded(.down))
        case .center:
            return max(0.0, ((viewportSize.width - last) / 2.0).rounded(.down))
        case .right:
            return 0.0
        }
    }

    /// The width the columns and their insets take up. Derived rather than read
    /// back from `contentSize`, so it is right before the layout is prepared.
    private var contentWidth: CGFloat {
        guard let lastOrigin = columnOrigins.last, let lastWidth = columnWidths.last else {
            return 0.0
        }

        return leadingInset + lastOrigin + lastWidth + trailingInset
    }

    /// The content offset at which a column rests under the selection indicator.
    ///
    /// Rounded to a whole point, and held inside the scrollable range, so the
    /// first and last column come to rest without hanging over an edge.
    func contentOffset(forColumn column: Int) -> CGPoint {
        guard columnWidths.indices.contains(column) else {
            return .zero
        }

        let frame = self.frame(forColumn: column)
        let width = viewportSize.width

        let offset: CGFloat
        switch selectionAlignment {
        case .left:
            offset = frame.minX
        case .center:
            offset = frame.midX - width / 2.0
        case .right:
            offset = frame.maxX - width
        }

        return CGPoint(x: min(max(offset.rounded(), 0.0), max(0.0, contentWidth - width)), y: 0.0)
    }

    /// The column resting nearest to a horizontal content offset.
    func column(nearestToContentOffset contentOffsetX: CGFloat) -> Int {
        var nearest = 0
        var nearestDelta = CGFloat.infinity

        // The resting offsets only increase, so the first column that is further
        // away than the one before it settles the answer.
        for column in columnWidths.indices {
            let delta = abs(contentOffset(forColumn: column).x - contentOffsetX)

            guard delta <= nearestDelta else {
                break
            }

            nearestDelta = delta
            nearest = column
        }

        return nearest
    }

    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint,
                                      withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard !columnWidths.isEmpty else {
            return proposedContentOffset
        }

        return contentOffset(forColumn: column(nearestToContentOffset: proposedContentOffset.x))
    }
}
