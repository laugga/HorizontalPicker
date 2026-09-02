/*

 LAUPickerTableView.swift
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

/// One component of a picker view: a single horizontal slider of columns.
///
/// The scroll mechanics live here. Columns are laid out left to right inside a
/// scroll view at their natural widths, the content inset places the selection
/// indicator, and dragging is snapped to the nearest column offset in
/// `scrollViewWillEndDragging`, which is what gives the control its deceleration
/// and its click.
@objc(LAUPickerTableView)
public class LAUPickerTableView: UIView {

    private static let hiddenColumnOpacity: Float = 0.0
    private static let shownColumnOpacity: Float = 0.5
    private static let selectedColumnOpacity: Float = 1.0

    private static let selectionAlignmentAnimationDuration: TimeInterval = 0.25
    private static let hiddenColumnsAnimationDuration: TimeInterval = 0.07

    /// Width of the band around the selected column that counts as a tap on it.
    private static let selectedColumnTouchInset: CGFloat = 30.0

    /// How long a touch has to rest on the selected column before the rest of
    /// the columns fade in.
    private static let showColumnsOnTouchDelay: TimeInterval = 0.2

    private static let defaultInterColumnSpacing: CGFloat = 5.5

    // MARK: - Public

    /// The index of the column currently under the selection indicator, or -1
    /// when the component is empty.
    @objc public private(set) var selectedColumn: Int = -1

    /// Sets the selection to the left edge, center or right edge.
    @objc public var selectionAlignment: LAUPickerSelectionAlignment {
        get {
            return storedSelectionAlignment
        }
        set {
            setSelectionAlignment(newValue, animated: false)
        }
    }

    private var storedSelectionAlignment: LAUPickerSelectionAlignment = .center

    @objc public weak var dataSource: LAUPickerTableViewDataSource?
    @objc public weak var delegate: LAUPickerTableViewDelegate?

    @objc public var isScrolling: Bool {
        return scrollView.isTracking || scrollView.isDragging || scrollView.isDecelerating
    }

    // MARK: - State

    private let component: Int
    private var numberOfColumns: Int = 0

    private var highlightedColumn: Int = -1
    private var maxSelectionRange: Int = -1 // [0, numberOfColumns-1]
    private var selectedColumnView: UIView?

    private var hiddenColumns: Bool = true
    private var isTouched: Bool = false

    // MARK: - Subviews

    private let scrollView: LAUPickerScrollView
    private var columns: [UIView] = []
    private var columnsOffset: [CGFloat] = []

    // MARK: - Layout

    private var interColumnSpacing: CGFloat = LAUPickerTableView.defaultInterColumnSpacing
    private var selectionEdgeInset: CGFloat = 0 // inset from left edge
    private var firstColumnOffset: CGFloat = 0
    private var contentWidth: CGFloat = 0 // content width for the columns
    private var contentWidthPadding: CGFloat = 0 // padding for the content width

    // MARK: - Initialization

    @objc(initWithFrame:andComponent:)
    public init(frame: CGRect, component: Int) {
        self.component = component
        self.scrollView = LAUPickerScrollView(frame: CGRect(origin: .zero, size: frame.size))

        super.init(frame: frame)

        autoresizesSubviews = true

        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        addSubview(scrollView)
    }

    public required init?(coder: NSCoder) {
        self.component = 0
        self.scrollView = LAUPickerScrollView(frame: .zero)

        super.init(coder: coder)

        autoresizesSubviews = true

        scrollView.frame = CGRect(origin: .zero, size: bounds.size)
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        addSubview(scrollView)
    }

    // MARK: - Layout

    public override func layoutSubviews() {
        super.layoutSubviews()

        setSelectionAlignment(selectionAlignment, animated: false)
    }

    private func updateScrollView(animated: Bool) {
        guard numberOfColumns > 0 else {
            return
        }

        if animated {
            UIView.animate(withDuration: LAUPickerTableView.selectionAlignmentAnimationDuration, animations: {
                self.applyScrollViewMetrics()
            }, completion: { _ in
                self.setSelectedColumn(self.selectedColumn, animated: true)
            })
        } else {
            applyScrollViewMetrics()
            setSelectedColumn(selectedColumn, animated: false)
        }
    }

    private func applyScrollViewMetrics() {
        scrollView.contentInset = UIEdgeInsets(top: 0, left: selectionEdgeInset, bottom: 0, right: 0)
        scrollView.contentSize = CGSize(width: contentWidth + contentWidthPadding, height: bounds.height)
    }

    private func scrollViewContentOffset(forColumn column: Int) -> CGPoint {
        guard column >= 0 && column < columnsOffset.count else {
            return .zero
        }

        return CGPoint(x: -firstColumnOffset + columnsOffset[column] + interColumnSpacing, y: 0)
    }

    @objc(setSelectedColumn:animated:)
    public func setSelectedColumn(_ column: Int, animated: Bool) {
        guard numberOfColumns > 0, column > -1, column < numberOfColumns else {
            return
        }

        selectedColumn = column
        selectedColumnView = columns[column]

        if animated {
            hideColumns(false, animated: true)
            scrollView.setContentOffset(scrollViewContentOffset(forColumn: column), animated: true)
        } else {
            scrollView.contentOffset = scrollViewContentOffset(forColumn: column)
        }
    }

    @objc(setSelectedColumnHighlighted:animated:)
    public func setSelectedColumnHighlighted(_ highlighted: Bool, animated: Bool) {
        guard selectedColumn > -1, selectedColumn < numberOfColumns else {
            return
        }

        if let label = columns[selectedColumn] as? LAUPickerViewLabel {
            label.setHighlighted(highlighted, animated: true)
        }
    }

    @objc(setSelectionAlignment:animated:)
    public func setSelectionAlignment(_ selectionAlignment: LAUPickerSelectionAlignment, animated: Bool) {
        storedSelectionAlignment = selectionAlignment

        guard dataSource != nil else {
            return
        }

        // The offset recorded for the first column is its width plus the spacing
        // that follows it; the layout below has always been measured against that.
        let firstColumnWidth = columnsOffset.first ?? 0.0

        switch selectionAlignment {
        case .left:
            selectionEdgeInset = frame.width - firstColumnWidth
            firstColumnOffset = firstColumnWidth
            contentWidthPadding = 0.0
        case .right:
            selectionEdgeInset = frame.width - firstColumnWidth
            firstColumnOffset = frame.width
            contentWidthPadding = 0.0
        case .center:
            selectionEdgeInset = bounds.width / 2.0 + firstColumnWidth / 2.0
            firstColumnOffset = bounds.width / 2.0 + firstColumnWidth / 2.0
            contentWidthPadding = selectionEdgeInset
        }

        // Recalculate and correct non-integer values
        selectionEdgeInset = selectionEdgeInset.rounded(.down)
        contentWidthPadding = contentWidthPadding.rounded(.down)

        updateScrollView(animated: animated)
    }

    private func updateHighlightedColumn(_ column: Int) {
        // Range is [0, numberOfColumns-1]
        let highlighted = max(0, min(column, maxSelectionRange))

        guard highlighted != highlightedColumn, highlighted >= 0, highlighted < columns.count else {
            return
        }

        if highlightedColumn > -1 { // Previous highlighted
            columns[highlightedColumn].layer.opacity = hiddenColumns
                ? LAUPickerTableView.hiddenColumnOpacity
                : LAUPickerTableView.shownColumnOpacity
        }

        columns[highlighted].layer.opacity = LAUPickerTableView.selectedColumnOpacity

        // Assign new value
        highlightedColumn = highlighted

        // Notify delegate only if due to user interaction
        if scrollView.isTracking || scrollView.isDragging || scrollView.isDecelerating {
            delegate?.pickerTableView(self, didHighlightColumn: highlighted, inComponent: component)
        }
    }

    @objc(viewForColumn:)
    public func viewForColumn(_ column: Int) -> UIView? {
        guard column > -1, column < columns.count else {
            return nil
        }

        return columns[column]
    }

    // MARK: - Data

    /// Reloads all columns in the table view.
    ///
    /// Safe to call at any point in the view's life: every piece of derived
    /// layout state is rebuilt from scratch, so rows that arrive after the view
    /// was created land the same way as rows that were there from the start.
    @objc public func reloadData() {
        // Clean up
        numberOfColumns = 0
        columns.removeAll()
        columnsOffset.removeAll()
        contentWidth = 0
        highlightedColumn = -1
        selectedColumn = -1
        selectedColumnView = nil
        hiddenColumns = true
        scrollView.subviews.forEach { $0.removeFromSuperview() }
        scrollView.contentSize = .zero

        guard let dataSource = dataSource else {
            return
        }

        numberOfColumns = dataSource.pickerTableView(self, numberOfColumnsInComponent: component)
        maxSelectionRange = numberOfColumns - 1

        interColumnSpacing = LAUPickerTableView.defaultInterColumnSpacing

        guard let delegate = delegate, numberOfColumns > 0 else {
            return
        }

        var cumulativeViewOffset: CGFloat = 0.0

        for column in 0..<numberOfColumns {
            let title = (delegate.pickerTableView?(self, titleForColumn: column, forComponent: component)) ?? nil
            let suppliedView = (delegate.pickerTableView?(self, viewForColumn: column, forComponent: component, reusingView: nil)) ?? nil

            let columnView: UIView

            if let suppliedView = suppliedView {
                if let title = title, let label = suppliedView as? UILabel {
                    label.text = title
                    label.sizeToFit()
                }

                columnView = suppliedView
            } else {
                let label = LAUPickerViewLabel()
                label.textColor = .black
                label.text = title
                label.textAlignment = .center
                label.backgroundColor = .clear

                // TODO expose in the LAUPickerView interface
                label.highlightedFont = .boldSystemFont(ofSize: 20.0)

                label.sizeToFit()

                columnView = label
            }

            let viewWidth = columnView.bounds.width
            let viewHeight = columnView.bounds.height

            columnView.frame = CGRect(x: cumulativeViewOffset, y: 0, width: viewWidth, height: viewHeight)

            cumulativeViewOffset += viewWidth + interColumnSpacing
            columnsOffset.append(cumulativeViewOffset)

            columnView.layer.opacity = LAUPickerTableView.hiddenColumnOpacity

            columns.append(columnView)
            scrollView.addSubview(columnView)

            contentWidth += viewWidth + interColumnSpacing
        }

        selectedColumn = 0
        selectedColumnView = columns.first

        // The alignment metrics are measured from the first column, which only
        // exists now — recompute them before placing the scroll view.
        setSelectionAlignment(selectionAlignment, animated: false)
    }

    private func column(forContentOffset contentOffset: CGFloat) -> Int {
        let targetOffset = contentOffset + firstColumnOffset
        var currentDelta = CGFloat.infinity
        var currentColumn = 0

        for column in 0..<columnsOffset.count {
            let delta = abs(columnsOffset[column] - targetOffset)
            if delta <= currentDelta {
                currentDelta = delta
                currentColumn = column
            } else {
                break
            }
        }

        return currentColumn
    }

    // MARK: - Show/Hide with Animation

    private func updateColumnsOpacity(_ opacity: Float) {
        for column in columns {
            // Skip selected column
            if column === selectedColumnView {
                column.layer.opacity = LAUPickerTableView.selectedColumnOpacity
                continue
            }

            column.layer.opacity = opacity
        }
    }

    @objc(hideColumns:animated:)
    public func hideColumns(_ hidden: Bool, animated: Bool) {
        if let shouldHide = delegate?.pickerTableView?(self, shouldHideUnselectedColumnsInComponent: component),
           shouldHide == false {
            if hiddenColumns {
                updateColumnsOpacity(LAUPickerTableView.shownColumnOpacity)
                hiddenColumns = false
            }
            return
        }

        if hidden == hiddenColumns {
            return
        }

        if !hidden && !(isTouched || scrollView.isDragging) {
            return
        }

        hiddenColumns = hidden

        let opacity = hidden ? LAUPickerTableView.hiddenColumnOpacity : LAUPickerTableView.shownColumnOpacity

        if animated {
            UIView.animate(withDuration: LAUPickerTableView.hiddenColumnsAnimationDuration,
                           delay: 0,
                           options: [.curveEaseIn],
                           animations: { self.updateColumnsOpacity(opacity) },
                           completion: nil)
        } else {
            updateColumnsOpacity(opacity)
        }
    }

    // MARK: - Touches

    private func doesTouchHitSelectedColumn(_ touch: UITouch) -> Bool {
        guard let selectedColumnView = viewForColumn(selectedColumn) else {
            return false
        }

        let inset = LAUPickerTableView.selectedColumnTouchInset
        let touchLocation = touch.location(in: self)
        let touchHitArea = CGRect(x: frame.width - selectedColumnView.frame.width - inset,
                                  y: 0,
                                  width: selectedColumnView.frame.width + 2.0 * inset,
                                  height: selectedColumnView.frame.height)

        return touchHitArea.contains(touchLocation)
    }
}

// MARK: - LAUPickerScrollViewDelegate

extension LAUPickerTableView: LAUPickerScrollViewDelegate {

    public func scrollViewTouchesDidBegin(_ scrollView: UIScrollView, withTouch touch: UITouch) {
        isTouched = true

        guard doesTouchHitSelectedColumn(touch) else {
            return // Empty touch down
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + LAUPickerTableView.showColumnsOnTouchDelay) { [weak self] in
            self?.hideColumns(false, animated: true)
        }
    }

    public func scrollViewTouchesDidEnd(_ scrollView: UIScrollView, withTouch touch: UITouch) {
        isTouched = false

        guard !scrollView.isDecelerating && !scrollView.isDragging else {
            return
        }

        hideColumns(true, animated: true)

        if doesTouchHitSelectedColumn(touch) {
            // Column touch up
            delegate?.pickerTableView?(self, didTouchUpColumn: selectedColumn, inComponent: component)
        } else {
            // Empty touch up
            delegate?.pickerTableView?(self, didTouchUp: touch, inComponent: component)
        }
    }
}

// MARK: - UIScrollViewDelegate

extension LAUPickerTableView {

    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        hideColumns(false, animated: false)
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Ignore if empty
        guard numberOfColumns > 0 else {
            return
        }

        updateHighlightedColumn(column(forContentOffset: scrollView.contentOffset.x))
    }

    public func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                          withVelocity velocity: CGPoint,
                                          targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        // Ignore if empty
        guard numberOfColumns > 0 else {
            return
        }

        let targetOffset = targetContentOffset.pointee.x + firstColumnOffset

        var currentOffset: CGFloat = 0.0
        var currentDelta = CGFloat.infinity

        for columnOffset in columnsOffset {
            let delta = abs(columnOffset - targetOffset)
            if delta <= currentDelta {
                currentDelta = delta
                currentOffset = columnOffset
            } else {
                break
            }
        }

        // Snap to the nearest column
        targetContentOffset.pointee.x = currentOffset - firstColumnOffset + interColumnSpacing
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            hideColumns(true, animated: true)
        }
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // Calculate selected column, range is [0, numberOfColumns-1]
        let column = max(0, min(self.column(forContentOffset: scrollView.contentOffset.x), maxSelectionRange))

        if column != selectedColumn, column > -1, column < numberOfColumns {
            // Assign new value
            selectedColumn = column
            selectedColumnView = columns[column]

            // Notify delegate
            delegate?.pickerTableView?(self, didChangeColumn: column, inComponent: component)
        }

        hideColumns(true, animated: true)
    }

    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        hideColumns(true, animated: true)
    }
}
