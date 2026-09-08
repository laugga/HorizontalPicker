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
/// The columns are a `UICollectionView` laid out by `LAUPickerColumnLayout`,
/// which owns the geometry — the column widths, the insets that place the
/// selection indicator, and the offset each column rests at. Snapping is the
/// layout's `targetContentOffset(forProposedContentOffset:withScrollingVelocity:)`,
/// and deceleration is the scroll view's own, so this class is left with what
/// the picker actually adds: which column is under the indicator, when to fade
/// the others in and out, and the tick played on the way past each one.
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

    // MARK: - Public

    /// The index of the column currently under the selection indicator, or -1
    /// when the component is empty.
    public private(set) var selectedColumn: Int = -1

    /// Sets the selection to the left edge, center or right edge.
    public var selectionAlignment: LAUPickerSelectionAlignment {
        get {
            return layout.selectionAlignment
        }
        set {
            setSelectionAlignment(newValue, animated: false)
        }
    }

    public weak var dataSource: LAUPickerTableViewDataSource?
    public weak var delegate: LAUPickerTableViewDelegate?

    public var isScrolling: Bool {
        return collectionView.isTracking || collectionView.isDragging || collectionView.isDecelerating
    }

    // MARK: - State

    /// A column is a title the picker draws itself, or a view the delegate
    /// supplied. Either way its width is what the layout places it against.
    private struct Column {

        enum Content {
            case title(String)
            case view(UIView)
        }

        let content: Content
        let width: CGFloat
    }

    private let component: Int

    private var columns: [Column] = []
    private var highlightedColumn: Int = -1
    private var hiddenColumns: Bool = true
    private var isTouched: Bool = false

    private var laidOutSize: CGSize = .zero

    // MARK: - Subviews

    private let layout: LAUPickerColumnLayout
    private let collectionView: UICollectionView
    private let touchRecognizer = LAUPickerTouchGestureRecognizer(target: nil, action: nil)

    // MARK: - Initialization

    public init(frame: CGRect, component: Int) {
        let layout = LAUPickerColumnLayout()

        self.component = component
        self.layout = layout
        self.collectionView = UICollectionView(frame: CGRect(origin: .zero, size: frame.size),
                                               collectionViewLayout: layout)

        super.init(frame: frame)

        setup()
    }

    public required init?(coder: NSCoder) {
        let layout = LAUPickerColumnLayout()

        self.component = 0
        self.layout = layout
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

        super.init(coder: coder)

        setup()
    }

    private func setup() {
        autoresizesSubviews = true

        collectionView.frame = bounds
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.allowsSelection = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(LAUPickerColumnCell.self,
                                forCellWithReuseIdentifier: LAUPickerColumnCell.reuseIdentifier)
        addSubview(collectionView)

        touchRecognizer.addTarget(self, action: #selector(handleTouch(_:)))
        touchRecognizer.delegate = self
        collectionView.addGestureRecognizer(touchRecognizer)
    }

    // MARK: - Layout

    public override func layoutSubviews() {
        super.layoutSubviews()

        collectionView.frame = bounds

        // The insets that place the selection indicator are measured against the
        // component's width, so a resize moves every column and the selection
        // has to be brought back under the indicator.
        guard bounds.size != laidOutSize else {
            return
        }

        laidOutSize = bounds.size

        collectionView.layoutIfNeeded()

        if !isScrolling {
            scrollToSelectedColumn(animated: false)
        }
    }

    public func setSelectionAlignment(_ selectionAlignment: LAUPickerSelectionAlignment, animated: Bool) {
        guard selectionAlignment != layout.selectionAlignment else {
            return
        }

        layout.selectionAlignment = selectionAlignment

        // Changing the alignment changes the insets, which moves every column;
        // laying the collection view out inside an animation block is what
        // carries the columns and the selection across rather than jumping them.
        let settle = {
            self.collectionView.layoutIfNeeded()
            self.scrollToSelectedColumn(animated: false)
        }

        if animated {
            UIView.animate(withDuration: LAUPickerTableView.selectionAlignmentAnimationDuration,
                           animations: settle)
        } else {
            settle()
        }
    }

    // MARK: - Data

    /// Reloads all columns in the component.
    ///
    /// Safe to call at any point in the view's life: the columns and everything
    /// derived from them are rebuilt from scratch, so columns that arrive after
    /// the view was created land the same way as columns that were there from
    /// the start.
    public func reloadData() {
        columns = loadColumns()
        layout.columnWidths = columns.map { $0.width }

        selectedColumn = columns.isEmpty ? -1 : 0
        highlightedColumn = selectedColumn
        hiddenColumns = true

        collectionView.reloadData()
        collectionView.layoutIfNeeded()

        scrollToSelectedColumn(animated: false)
    }

    private func loadColumns() -> [Column] {
        guard let dataSource = dataSource, let delegate = delegate else {
            return []
        }

        let numberOfColumns = dataSource.pickerTableView(self, numberOfColumnsInComponent: component)

        guard numberOfColumns > 0 else {
            return []
        }

        return (0..<numberOfColumns).map { column in
            let title = delegate.pickerTableView(self, titleForColumn: column, forComponent: component)

            // A view the delegate supplies has to be built now rather than when
            // its cell comes round: its width is what the layout places the
            // column at, and only the view itself knows what that is.
            let suppliedView = delegate.pickerTableView(self,
                                                        viewForColumn: column,
                                                        forComponent: component,
                                                        reusingView: nil)

            if let suppliedView = suppliedView {
                if let title = title, let label = suppliedView as? UILabel {
                    label.text = title
                    label.sizeToFit()
                }

                return Column(content: .view(suppliedView), width: suppliedView.bounds.width)
            }

            let columnTitle = title ?? ""

            return Column(content: .title(columnTitle),
                          width: LAUPickerColumnCell.width(forTitle: columnTitle))
        }
    }

    // MARK: - Selection

    public func setSelectedColumn(_ column: Int, animated: Bool) {
        guard columns.indices.contains(column) else {
            return
        }

        selectedColumn = column

        scrollToSelectedColumn(animated: animated)
        updateHighlightedColumn(column)
    }

    public func viewForColumn(_ column: Int) -> UIView? {
        guard columns.indices.contains(column) else {
            return nil
        }

        // A view the delegate supplied is held for as long as the column is; a
        // title is only drawn while its cell is on screen.
        if case .view(let suppliedView) = columns[column].content {
            return suppliedView
        }

        return cell(forColumn: column)?.hostedView
    }

    private func cell(forColumn column: Int) -> LAUPickerColumnCell? {
        return collectionView.cellForItem(at: IndexPath(item: column, section: 0)) as? LAUPickerColumnCell
    }

    private func scrollToSelectedColumn(animated: Bool) {
        guard columns.indices.contains(selectedColumn) else {
            return
        }

        let contentOffset = layout.contentOffset(forColumn: selectedColumn)

        if animated {
            hideColumns(false, animated: true)
            collectionView.setContentOffset(contentOffset, animated: true)
        } else {
            collectionView.contentOffset = contentOffset
        }
    }

    /// Takes the column now under the selection indicator as the selected one,
    /// and tells the delegate if it changed.
    private func commitSelectedColumn() {
        let column = layout.column(nearestToContentOffset: collectionView.contentOffset.x)

        guard columns.indices.contains(column), column != selectedColumn else {
            return
        }

        selectedColumn = column

        delegate?.pickerTableView(self, didChangeColumn: column, inComponent: component)
    }

    private func updateHighlightedColumn(_ column: Int) {
        guard columns.indices.contains(column), column != highlightedColumn else {
            return
        }

        highlightedColumn = column
        applyColumnOpacity()

        // Only a column the user brought under the indicator is worth a tick.
        if isScrolling {
            delegate?.pickerTableView(self, didHighlightColumn: column, inComponent: component)
        }
    }

    // MARK: - Show/Hide with Animation

    private func opacity(forColumn column: Int) -> Float {
        if column == highlightedColumn {
            return LAUPickerTableView.selectedColumnOpacity
        }

        return hiddenColumns ? LAUPickerTableView.hiddenColumnOpacity : LAUPickerTableView.shownColumnOpacity
    }

    private func applyColumnOpacity() {
        for cell in collectionView.visibleCells {
            guard let cell = cell as? LAUPickerColumnCell,
                  let indexPath = collectionView.indexPath(for: cell) else {
                continue
            }

            cell.columnOpacity = opacity(forColumn: indexPath.item)
        }
    }

    public func hideColumns(_ hidden: Bool, animated: Bool) {
        if delegate?.pickerTableView(self, shouldHideUnselectedColumnsInComponent: component) == false {
            guard hiddenColumns else {
                return
            }

            hiddenColumns = false
            applyColumnOpacity()
            return
        }

        guard hidden != hiddenColumns else {
            return
        }

        // The columns only come back for a finger that is on the control.
        guard hidden || isTouched || collectionView.isDragging else {
            return
        }

        hiddenColumns = hidden

        if animated {
            UIView.animate(withDuration: LAUPickerTableView.hiddenColumnsAnimationDuration,
                           delay: 0,
                           options: [.curveEaseIn],
                           animations: { self.applyColumnOpacity() },
                           completion: nil)
        } else {
            applyColumnOpacity()
        }
    }

    // MARK: - Touches

    @objc private func handleTouch(_ recognizer: LAUPickerTouchGestureRecognizer) {
        switch recognizer.state {
        case .began:
            isTouched = true

            guard hitsSelectedColumn(recognizer.location(in: self)) else {
                return // Empty touch down
            }

            // A finger resting on the selected column reveals the rest of them.
            DispatchQueue.main.asyncAfter(deadline: .now() + LAUPickerTableView.showColumnsOnTouchDelay) { [weak self] in
                guard let self = self, self.isTouched else {
                    return
                }

                self.hideColumns(false, animated: true)
            }

        case .ended, .cancelled, .failed:
            guard isTouched else {
                return
            }

            isTouched = false

            // A lift that hands the control over to the scroll view is the
            // scroll view's to finish.
            guard !collectionView.isDragging, !collectionView.isDecelerating else {
                return
            }

            hideColumns(true, animated: true)

            if hitsSelectedColumn(recognizer.location(in: self)) {
                // Column touch up
                delegate?.pickerTableView(self, didTouchUpColumn: selectedColumn, inComponent: component)
            } else if let touch = recognizer.currentTouch {
                // Empty touch up
                delegate?.pickerTableView(self, didTouchUp: touch, inComponent: component)
            }

        default:
            break
        }
    }

    private func hitsSelectedColumn(_ location: CGPoint) -> Bool {
        guard columns.indices.contains(selectedColumn) else {
            return false
        }

        let columnFrame = collectionView.convert(layout.frame(forColumn: selectedColumn), to: self)

        return columnFrame.insetBy(dx: -LAUPickerTableView.selectedColumnTouchInset, dy: 0).contains(location)
    }
}

// MARK: - UIGestureRecognizerDelegate

extension LAUPickerTableView: UIGestureRecognizerDelegate {

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                  shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // Watching the touches must not stand in the way of the scrolling.
        return true
    }
}

// MARK: - UICollectionViewDataSource

extension LAUPickerTableView: UICollectionViewDataSource {

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return columns.count
    }

    public func collectionView(_ collectionView: UICollectionView,
                               cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let dequeued = collectionView.dequeueReusableCell(withReuseIdentifier: LAUPickerColumnCell.reuseIdentifier,
                                                          for: indexPath)

        guard let cell = dequeued as? LAUPickerColumnCell, columns.indices.contains(indexPath.item) else {
            return dequeued
        }

        switch columns[indexPath.item].content {
        case .title(let title):
            cell.showTitle(title)
        case .view(let suppliedView):
            cell.showView(suppliedView)
        }

        cell.columnOpacity = opacity(forColumn: indexPath.item)

        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension LAUPickerTableView: UICollectionViewDelegate {

    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        hideColumns(false, animated: false)
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !columns.isEmpty else {
            return
        }

        updateHighlightedColumn(layout.column(nearestToContentOffset: scrollView.contentOffset.x))
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard !decelerate else {
            return
        }

        commitSelectedColumn()
        hideColumns(true, animated: true)
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        commitSelectedColumn()
        hideColumns(true, animated: true)
    }

    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        hideColumns(true, animated: true)
    }
}
