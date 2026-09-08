/*

 LAUPickerView.swift
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

/// An horizontal *spinning-wheel* picker control.
///
/// Similar to `UIPickerView`, but the user interface consists of columns rather
/// than rows, and it follows the same semantics for its data source and delegate
/// methods. A component is a slider with a series of columns at indexed
/// locations; each column's content is either a title or a view.
public class LAUPickerView: UIView {

    // MARK: - Public

    /// The data source for the picker view, which supplies the number of
    /// components and the number of columns in each of them.
    public weak var dataSource: LAUPickerViewDataSource? {
        didSet {
            reloadDataIfNeeded()
        }
    }

    /// The delegate for the picker view, which supplies the content of each
    /// column and is told about new selections.
    public weak var delegate: LAUPickerViewDelegate? {
        didSet {
            reloadDataIfNeeded()
        }
    }

    /// The alignment of the picker view selection indicator. Defaults to
    /// `.center`.
    public var selectionAlignment: LAUPickerSelectionAlignment {
        get {
            return storedSelectionAlignment
        }
        set {
            storedSelectionAlignment = newValue

            for table in tables {
                table.selectionAlignment = newValue
            }
        }
    }

    private var storedSelectionAlignment: LAUPickerSelectionAlignment = .center

    /// The input sounds of the picker view are played when the selection
    /// changes. Defaults to `true`.
    public var soundsEnabled: Bool = true

    /// The input haptic patterns of the picker view are played when the
    /// selection changes. Defaults to `true`.
    public var hapticsEnabled: Bool = true

    /// Hides unselected columns when the picker is not being scrolled. Defaults
    /// to `true`.
    public var hidesUnselectedColumns: Bool = true {
        didSet {
            for table in tables {
                table.hideColumns(hidesUnselectedColumns, animated: false)
            }
        }
    }

    /// The number of components the data source supplied.
    public private(set) var numberOfComponents: Int = 0

    // MARK: - State

    private var tables: [LAUPickerTableView] = []

    /// The delegate answers the component geometry, and its protocol extension
    /// supplies the defaults — so a picker whose delegate has gone away lays
    /// itself out the same way as one whose delegate leaves those alone.
    private var layoutDelegate: LAUPickerViewDelegate {
        return delegate ?? LAUPickerView.defaultDelegate
    }

    private static let defaultDelegate: LAUPickerViewDelegate = DefaultDelegate()

    private final class DefaultDelegate: LAUPickerViewDelegate {}

    private let feedbackGenerator = UISelectionFeedbackGenerator()

    // MARK: - Initialization

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        feedbackGenerator.prepare()
    }

    // MARK: - Layout

    public func setSelectionAlignment(_ selectionAlignment: LAUPickerSelectionAlignment, animated: Bool) {
        storedSelectionAlignment = selectionAlignment

        for table in tables {
            table.setSelectionAlignment(selectionAlignment, animated: animated)
        }
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        // The component frames are derived from the picker's own size, which
        // under Auto Layout is not known when the data source is first set.
        // Re-deriving them here is what lets rows be supplied before the picker
        // has been laid out.
        for (component, table) in tables.enumerated() {
            let frame = frameForComponent(component)
            if table.frame != frame {
                table.frame = frame
            }
        }
    }

    private func frameForComponent(_ component: Int) -> CGRect {
        let delegate = layoutDelegate

        return CGRect(x: 0,
                      y: delegate.pickerView(self, topSpaceForComponent: component),
                      width: bounds.width,
                      height: delegate.pickerView(self, heightForComponent: component))
    }

    // MARK: - Data

    private func reloadDataIfNeeded() {
        guard dataSource != nil, delegate != nil, numberOfComponents == 0 else {
            return
        }

        reloadData()
    }

    /// Reloads all columns for all components.
    ///
    /// Safe to call at any point in the picker's life, so a data source whose
    /// rows only arrive later can call it once they have.
    public func reloadData() {
        numberOfComponents = 0

        // Clean up
        tables.removeAll()
        subviews.forEach { $0.removeFromSuperview() }

        guard let dataSource = dataSource, let delegate = delegate else {
            return
        }

        numberOfComponents = dataSource.numberOfComponents(in: self)

        var accessibilityIdentifier = ""

        for component in 0..<numberOfComponents {
            if let identifier = delegate.pickerView(self, accessibilityIdentifierForComponent: component) {
                accessibilityIdentifier = identifier
            }

            let tableView = LAUPickerTableView(frame: frameForComponent(component), component: component)
            tableView.accessibilityIdentifier = accessibilityIdentifier
            tableView.dataSource = self
            tableView.delegate = self
            tableView.autoresizingMask = .flexibleWidth
            tableView.reloadData()
            tables.append(tableView)
            addSubview(tableView)

            tableView.selectionAlignment = storedSelectionAlignment
        }
    }

    // MARK: - Selection

    /// Returns the index of the selected column in a given component, or -1 if
    /// no column is selected.
    public func selectedColumn(inComponent component: Int) -> Int {
        guard component >= 0, component < tables.count else {
            return -1
        }

        return tables[component].selectedColumn
    }

    /// Selects a column in a specified component of the picker view.
    public func selectColumn(_ column: Int, inComponent component: Int, animated: Bool) {
        guard component >= 0, component < tables.count else {
            return
        }

        tables[component].setSelectedColumn(column, animated: animated)
    }

    // MARK: - Animation

    public func showComponent(_ shownComponent: Int, andHideComponent hiddenComponent: Int, animated: Bool) {
        guard shownComponent >= 0, shownComponent < tables.count,
              hiddenComponent >= 0, hiddenComponent < tables.count else {
            return
        }

        let shownTable = tables[shownComponent]
        let hiddenTable = tables[hiddenComponent]

        guard animated else {
            shownTable.alpha = 1.0
            hiddenTable.alpha = 0.0

            shownTable.hideColumns(true, animated: false)
            hiddenTable.hideColumns(true, animated: false)
            return
        }

        let delay = 0.1

        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            shownTable.alpha = 0.0

            let shownAnimationScale = shownTable.frame.height / hiddenTable.frame.height
            let hiddenAnimationScale = 1.0 / shownAnimationScale
            let hiddenAnimationTranslate: CGFloat = hiddenAnimationScale > 1.0 ? -50.0 : 70.0
            let shownAnimationTranslate: CGFloat = shownAnimationScale > 1.0 ? 60.0 : 240.0

            shownTable.transform = CGAffineTransform(scaleX: hiddenAnimationScale, y: hiddenAnimationScale)
                .translatedBy(x: hiddenAnimationTranslate, y: 0)

            UIView.animate(withDuration: 0.3,
                           delay: 0.0,
                           usingSpringWithDamping: 1.0,
                           initialSpringVelocity: 0.0,
                           options: [.beginFromCurrentState, .curveEaseInOut],
                           animations: {
                shownTable.transform = .identity
                shownTable.alpha = 1.0

                hiddenTable.transform = CGAffineTransform(scaleX: shownAnimationScale / 2.0, y: shownAnimationScale / 2.0)
                    .translatedBy(x: shownAnimationTranslate, y: 0)
                hiddenTable.alpha = 0.0
            }, completion: { _ in
                hiddenTable.transform = .identity

                shownTable.hideColumns(true, animated: true)
                hiddenTable.hideColumns(true, animated: true)
            })
        }
    }
}

// MARK: - LAUPickerTableViewDataSource

extension LAUPickerView: LAUPickerTableViewDataSource {

    public func pickerTableView(_ pickerTableView: LAUPickerTableView, numberOfColumnsInComponent component: Int) -> Int {
        guard let dataSource = dataSource else {
            return 0
        }

        return dataSource.pickerView(self, numberOfColumnsInComponent: component)
    }
}

// MARK: - LAUPickerTableViewDelegate

extension LAUPickerView: LAUPickerTableViewDelegate {

    public func pickerTableView(_ pickerTableView: LAUPickerTableView, didHighlightColumn column: Int, inComponent component: Int) {
        if soundsEnabled {
            // Play sound when the highlighted column changes
            LAUPickerTableInputSound.shared.play()
        }

        if hapticsEnabled {
            feedbackGenerator.selectionChanged()
            feedbackGenerator.prepare()
        }
    }

    public func pickerTableView(_ pickerTableView: LAUPickerTableView, titleForColumn column: Int, forComponent component: Int) -> String? {
        return delegate?.pickerView(self, titleForColumn: column, forComponent: component)
    }

    public func pickerTableView(_ pickerTableView: LAUPickerTableView, viewForColumn column: Int, forComponent component: Int, reusingView view: UIView?) -> UIView? {
        // Reuse is not passed on: the Objective-C version has always asked the
        // delegate for a fresh view, and the columns are all built up front.
        return delegate?.pickerView(self, viewForColumn: column, forComponent: component, reusingView: nil)
    }

    public func pickerTableView(_ pickerTableView: LAUPickerTableView, didChangeColumn column: Int, inComponent component: Int) {
        delegate?.pickerView(self, didChangeColumn: column, inComponent: component)
    }

    public func pickerTableView(_ pickerTableView: LAUPickerTableView, didTouchUpColumn column: Int, inComponent component: Int) {
        delegate?.pickerView(self, didTouchUpColumn: column, inComponent: component)
    }

    public func pickerTableView(_ pickerTableView: LAUPickerTableView, didTouchUp touch: UITouch, inComponent component: Int) {
        delegate?.pickerView(self, didTouchUp: touch, inComponent: component)
    }

    public func pickerTableView(_ pickerTableView: LAUPickerTableView, shouldHideUnselectedColumnsInComponent component: Int) -> Bool {
        return hidesUnselectedColumns
    }
}
