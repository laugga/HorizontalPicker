//
//  LAUPickerViewTests.swift
//  HorizontalPickerTests
//
//  Copyright © 2022 Luis Laugga. All rights reserved.
//

import UIKit
import XCTest

import HorizontalPicker

/// A data source and delegate whose rows can be swapped at any point, so the
/// tests can supply them before and after the picker exists.
private class PickerSource: NSObject, LAUPickerViewDataSource, LAUPickerViewDelegate {

    var components: [[String]]

    var columnViews: [Int: UIView] = [:]
    var componentHeight: CGFloat?

    private(set) var changedColumns: [(column: Int, component: Int)] = []

    init(components: [[String]]) {
        self.components = components
    }

    func numberOfComponents(in pickerView: LAUPickerView) -> Int {
        return components.count
    }

    func pickerView(_ pickerView: LAUPickerView, numberOfColumnsInComponent component: Int) -> Int {
        return components[component].count
    }

    func pickerView(_ pickerView: LAUPickerView, titleForColumn column: Int, forComponent component: Int) -> String {
        return components[component][column]
    }

    func pickerView(_ pickerView: LAUPickerView, didChangeColumn column: Int, inComponent component: Int) {
        changedColumns.append((column, component))
    }
}

/// A source that also answers `viewForColumn:`, to cover the delegate-supplied
/// column views.
private class ViewSuppliedSource: PickerSource {

    func pickerView(_ pickerView: LAUPickerView, viewForColumn column: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        let label = UILabel()
        label.text = components[component][column]
        label.sizeToFit()
        columnViews[column] = label
        return label
    }
}

class LAUPickerViewTests: XCTestCase {

    private let frame = CGRect(x: 0, y: 0, width: 320, height: 150)

    private func makePickerView(_ source: PickerSource) -> LAUPickerView {
        let pickerView = LAUPickerView(frame: frame)
        pickerView.dataSource = source
        pickerView.delegate = source
        pickerView.layoutIfNeeded()
        return pickerView
    }

    // MARK: - Defaults

    func testDefaults() throws {
        let pickerView = LAUPickerView(frame: frame)

        XCTAssertEqual(pickerView.selectionAlignment, .center)
        XCTAssertTrue(pickerView.soundsEnabled)
        XCTAssertTrue(pickerView.hapticsEnabled)
        XCTAssertTrue(pickerView.hidesUnselectedColumns)
    }

    func testNoComponentsWithoutADataSource() throws {
        let pickerView = LAUPickerView(frame: frame)

        XCTAssertTrue(pickerView.subviews.isEmpty)
        XCTAssertEqual(pickerView.selectedColumn(inComponent: 0), -1)
    }

    // MARK: - Data source and delegate contract

    func testDataSourceSuppliesOneComponentPerSlider() throws {
        let source = PickerSource(components: [["1.4", "2.0", "2.8"], ["50", "100"]])
        let pickerView = makePickerView(source)

        XCTAssertEqual(pickerView.subviews.count, 2)
    }

    func testFirstColumnIsSelectedOnLoad() throws {
        let source = PickerSource(components: [["1.4", "2.0", "2.8"]])
        let pickerView = makePickerView(source)

        XCTAssertEqual(pickerView.selectedColumn(inComponent: 0), 0)
    }

    func testSelectingAColumnOutOfRangeLeavesTheSelectionAlone() throws {
        let source = PickerSource(components: [["1.4", "2.0", "2.8"]])
        let pickerView = makePickerView(source)

        pickerView.selectColumn(9, inComponent: 0, animated: false)

        XCTAssertEqual(pickerView.selectedColumn(inComponent: 0), 0)
    }

    func testSelectedColumnOfAnUnknownComponentIsNotSelected() throws {
        let source = PickerSource(components: [["1.4", "2.0"]])
        let pickerView = makePickerView(source)

        XCTAssertEqual(pickerView.selectedColumn(inComponent: 7), -1)
    }

    func testSelectingAColumnReportsItBack() throws {
        let source = PickerSource(components: [["1.4", "2.0", "2.8"], ["50", "100"]])
        let pickerView = makePickerView(source)

        pickerView.selectColumn(2, inComponent: 0, animated: false)
        pickerView.selectColumn(1, inComponent: 1, animated: false)

        XCTAssertEqual(pickerView.selectedColumn(inComponent: 0), 2)
        XCTAssertEqual(pickerView.selectedColumn(inComponent: 1), 1)
    }

    func testColumnsFallBackToLabelsBuiltFromTheTitles() throws {
        let source = PickerSource(components: [["1.4", "2.0", "2.8"]])
        let pickerView = makePickerView(source)

        let labels = columnLabels(of: pickerView)

        XCTAssertEqual(labels.map { $0.text }, ["1.4", "2.0", "2.8"])
    }

    func testDelegateSuppliedViewsAreUsedForTheColumns() throws {
        let source = ViewSuppliedSource(components: [["1.4", "2.0"]])
        let pickerView = makePickerView(source)

        let labels = columnLabels(of: pickerView)

        XCTAssertEqual(labels.count, 2)
        XCTAssertTrue(labels.allSatisfy { !($0 is LAUPickerViewLabel) })
    }

    // MARK: - Rows supplied after init

    func testRowsCanBeSuppliedAfterInit() throws {
        let source = PickerSource(components: [])
        let pickerView = makePickerView(source)

        XCTAssertTrue(pickerView.subviews.isEmpty)

        source.components = [["1.4", "2.0", "2.8"]]
        pickerView.reloadData()
        pickerView.layoutIfNeeded()

        XCTAssertEqual(pickerView.subviews.count, 1)
        XCTAssertEqual(pickerView.selectedColumn(inComponent: 0), 0)
        XCTAssertEqual(columnLabels(of: pickerView).map { $0.text }, ["1.4", "2.0", "2.8"])
    }

    func testReloadingReplacesTheColumnsRatherThanAddingToThem() throws {
        let source = PickerSource(components: [["1.4", "2.0", "2.8"]])
        let pickerView = makePickerView(source)

        source.components = [["50", "100"]]
        pickerView.reloadData()
        pickerView.layoutIfNeeded()

        XCTAssertEqual(pickerView.subviews.count, 1)
        XCTAssertEqual(columnLabels(of: pickerView).map { $0.text }, ["50", "100"])
    }

    func testReloadingIsIdempotent() throws {
        let source = PickerSource(components: [["1.4", "2.0", "2.8"], ["50", "100"]])
        let pickerView = makePickerView(source)

        let contentSizes = scrollViewContentSizes(of: pickerView)

        pickerView.reloadData()
        pickerView.layoutIfNeeded()

        XCTAssertEqual(pickerView.subviews.count, 2)
        XCTAssertEqual(scrollViewContentSizes(of: pickerView), contentSizes)
    }

    // MARK: - Layout

    func testComponentsShareThePickerHeightWhenTheDelegateDoesNotSayOtherwise() throws {
        let source = PickerSource(components: [["1.4"], ["50"], ["1/60"]])
        let pickerView = makePickerView(source)

        let heights = pickerView.subviews.map { $0.frame.height }
        let tops = pickerView.subviews.map { $0.frame.minY }

        XCTAssertEqual(heights, [50, 50, 50])
        XCTAssertEqual(tops, [0, 50, 100])
    }

    func testComponentFramesFollowThePickerBeingResized() throws {
        let source = PickerSource(components: [["1.4"], ["50"]])
        let pickerView = makePickerView(source)

        pickerView.frame = CGRect(x: 0, y: 0, width: 480, height: 200)
        pickerView.layoutIfNeeded()

        XCTAssertEqual(pickerView.subviews.map { $0.frame.width }, [480, 480])
        XCTAssertEqual(pickerView.subviews.map { $0.frame.height }, [100, 100])
    }

    func testSelectionAlignmentReachesEveryComponent() throws {
        let source = PickerSource(components: [["1.4", "2.0"], ["50", "100"]])
        let pickerView = makePickerView(source)

        pickerView.setSelectionAlignment(.left, animated: false)

        XCTAssertEqual(pickerView.selectionAlignment, .left)
        for table in pickerView.subviews.compactMap({ $0 as? LAUPickerTableView }) {
            XCTAssertEqual(table.selectionAlignment, .left)
        }
    }

    // MARK: - Scroll mechanics

    func testEndingADragSnapsToTheNearestColumn() throws {
        let source = PickerSource(components: [["1.0", "1.1", "1.2", "1.4", "1.6"]])
        let pickerView = makePickerView(source)
        let table = try firstTable(of: pickerView)
        let scrollView = try self.scrollView(of: table)

        let offsets = contentOffsets(of: pickerView, columns: source.components[0].count, scrollView: scrollView)

        for (column, offset) in offsets.enumerated() {
            for drift in [CGFloat(-3.0), CGFloat(3.0)] {
                var target = CGPoint(x: offset + drift, y: 0)
                table.scrollViewWillEndDragging(scrollView, withVelocity: .zero, targetContentOffset: &target)

                // Read back through the scroll view, the resting offset is quantised to the
                // pixel grid; the snap itself is computed exactly.
                XCTAssertEqual(target.x, offset, accuracy: 0.5, "column \(column) drifted by \(drift)")
            }
        }
    }

    func testADragPastTheLastColumnSnapsBackToIt() throws {
        let source = PickerSource(components: [["1.0", "1.1", "1.2"]])
        let pickerView = makePickerView(source)
        let table = try firstTable(of: pickerView)
        let scrollView = try self.scrollView(of: table)

        let offsets = contentOffsets(of: pickerView, columns: source.components[0].count, scrollView: scrollView)

        var target = CGPoint(x: (offsets.last ?? 0) + 500.0, y: 0)
        table.scrollViewWillEndDragging(scrollView, withVelocity: .zero, targetContentOffset: &target)

        XCTAssertEqual(target.x, offsets.last ?? 0, accuracy: 0.5)
    }

    func testScrollingHighlightsTheColumnUnderTheIndicator() throws {
        let source = PickerSource(components: [["1.0", "1.1", "1.2", "1.4", "1.6"]])
        let pickerView = makePickerView(source)
        let table = try firstTable(of: pickerView)
        let scrollView = try self.scrollView(of: table)

        let offsets = contentOffsets(of: pickerView, columns: source.components[0].count, scrollView: scrollView)

        scrollView.contentOffset = CGPoint(x: offsets[3], y: 0)

        let opacities = columnLabels(of: pickerView).map { $0.layer.opacity }

        XCTAssertEqual(opacities, [0.0, 0.0, 0.0, 1.0, 0.0])
    }

    // MARK: - Unselected columns

    func testUnselectedColumnsAreHiddenByDefault() throws {
        let source = PickerSource(components: [["1.4", "2.0", "2.8"]])
        let pickerView = makePickerView(source)

        let opacities = columnLabels(of: pickerView).map { $0.layer.opacity }

        // Only the column under the selection indicator is drawn at rest.
        XCTAssertEqual(opacities, [1.0, 0.0, 0.0])
    }

    func testUnselectedColumnsStayVisibleWhenHidingIsTurnedOff() throws {
        let source = PickerSource(components: [["1.4", "2.0", "2.8"]])
        let pickerView = makePickerView(source)

        pickerView.hidesUnselectedColumns = false

        let opacities = columnLabels(of: pickerView).map { $0.layer.opacity }

        XCTAssertEqual(opacities, [1.0, 0.5, 0.5])
    }

    // MARK: - Helpers

    private func columnLabels(of pickerView: LAUPickerView) -> [UILabel] {
        return pickerView.subviews
            .compactMap { $0 as? LAUPickerTableView }
            .flatMap { $0.subviews }
            .compactMap { $0 as? UIScrollView }
            .flatMap { $0.subviews }
            .compactMap { $0 as? UILabel }
    }

    private func firstTable(of pickerView: LAUPickerView) throws -> LAUPickerTableView {
        return try XCTUnwrap(pickerView.subviews.compactMap { $0 as? LAUPickerTableView }.first)
    }

    private func scrollView(of table: LAUPickerTableView) throws -> UIScrollView {
        return try XCTUnwrap(table.subviews.compactMap { $0 as? UIScrollView }.first)
    }

    /// The resting content offset of each column, read back from the scroll view
    /// after selecting it.
    private func contentOffsets(of pickerView: LAUPickerView, columns: Int, scrollView: UIScrollView) -> [CGFloat] {
        return (0..<columns).map { column in
            pickerView.selectColumn(column, inComponent: 0, animated: false)
            return scrollView.contentOffset.x
        }
    }

    private func scrollViewContentSizes(of pickerView: LAUPickerView) -> [CGSize] {
        return pickerView.subviews
            .compactMap { $0 as? LAUPickerTableView }
            .flatMap { $0.subviews }
            .compactMap { $0 as? UIScrollView }
            .map { $0.contentSize }
    }
}
