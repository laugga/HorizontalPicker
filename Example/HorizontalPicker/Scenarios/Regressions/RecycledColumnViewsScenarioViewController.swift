//
//  RecycledColumnViewsScenarioViewController.swift
//  HorizontalPicker
//

import UIKit
import HorizontalPicker

/// The state behind LM-603: a component long enough for its cells to be
/// recycled, every column of it a view the delegate supplied.
///
/// A supplied view is built once and re-parented into whichever cell is showing
/// its column. A cell that has gone off screen keeps referring to a view that
/// has since moved on, and used to take it back when it was next dequeued —
/// leaving the column on screen blank. Small drags back and forth are what
/// reproduce it; a jump straight to a far column does not.
///
/// Each column is tinted, so a column that has lost its view reads as a gap
/// rather than as blank space that might just be a wide column.
final class RecycledColumnViewsScenarioViewController: ScenarioViewController,
                                                       LAUPickerViewDataSource,
                                                       LAUPickerViewDelegate {

    private static let columnCount = 200

    private static let componentHeight: CGFloat = 50.0

    private let picker = LAUPickerView()

    override func viewDidLoad() {
        super.viewDidLoad()

        picker.dataSource = self
        picker.delegate = self

        // Every column stays on screen, so one that has gone blank is visible
        // without having to drag the picker to reveal it.
        picker.hidesUnselectedColumns = false

        add(picker, height: Self.componentHeight)
        addNote("Drag the component forward and back in small steps, several times over. Every column should keep its tinted label — a column that goes blank is LM-603 come back.")
    }

    // MARK: - LAUPickerViewDataSource

    func numberOfComponents(in pickerView: LAUPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: LAUPickerView, numberOfColumnsInComponent component: Int) -> Int {
        return Self.columnCount
    }

    // MARK: - LAUPickerViewDelegate

    func pickerView(_ pickerView: LAUPickerView, heightForComponent component: Int) -> CGFloat {
        return Self.componentHeight
    }

    func pickerView(_ pickerView: LAUPickerView, titleForColumn column: Int, forComponent component: Int) -> String? {
        return String(column)
    }

    func pickerView(_ pickerView: LAUPickerView, viewForColumn column: Int, forComponent component: Int, reusingView view: UIView?) -> UIView? {
        // A label, which is what both of the app's call sites hand over, and the
        // shape the bug was reported against.
        let label = UILabel()
        label.text = String(column)
        label.font = .systemFont(ofSize: 20.0, weight: .semibold)
        label.textAlignment = .center
        label.textColor = .white
        label.backgroundColor = UIColor(hue: CGFloat(column % 20) / 20.0,
                                        saturation: 0.65,
                                        brightness: 0.85,
                                        alpha: 1.0)
        label.sizeToFit()
        label.bounds.size.width += 16.0

        return label
    }
}

#if DEBUG
#Preview("Recycled column views") {
    RecycledColumnViewsScenarioViewController()
}
#endif
