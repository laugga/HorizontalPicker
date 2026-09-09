//
//  NativeComparisonScenarioViewController.swift
//  HorizontalPicker
//

import UIKit
import HorizontalPicker

/// The same three components shown twice: `LAUPickerView` at the top and the
/// native `UIPickerView` at the bottom, over the same values.
///
/// The two are kept in step in both directions — spinning a column of the
/// horizontal picker moves the matching row of the native one, and spinning a
/// row of the native one moves the matching column back — so the port can be
/// compared against the control it is modelled on side by side.
///
/// This is the screen the repository's original `LAUPickerViewExample` showed,
/// rebuilt without the storyboard it used to be laid out in.
final class NativeComparisonScenarioViewController: ScenarioViewController,
                                                    LAUPickerViewDelegate,
                                                    LAUPickerViewDataSource,
                                                    UIPickerViewDelegate,
                                                    UIPickerViewDataSource {

    private let horizontalPickerView = LAUPickerView()

    private let nativePickerView = UIPickerView()

    override func viewDidLoad() {
        super.viewDidLoad()

        horizontalPickerView.dataSource = self
        horizontalPickerView.delegate = self
        horizontalPickerView.hidesUnselectedColumns = false

        nativePickerView.dataSource = self
        nativePickerView.delegate = self

        add(horizontalPickerView, height: 150.0)
        add(nativePickerView, height: 180.0)
        addNote("Spinning either picker moves the other. Unselected columns are left visible so the two can be read against each other.")
    }

    // MARK: - LAUPickerViewDataSource

    func numberOfComponents(in pickerView: LAUPickerView) -> Int {
        return ExposureValues.allCases.count
    }

    func pickerView(_ pickerView: LAUPickerView, numberOfColumnsInComponent component: Int) -> Int {
        return values(forComponent: component).count
    }

    // MARK: - LAUPickerViewDelegate

    func pickerView(_ pickerView: LAUPickerView, heightForComponent component: Int) -> CGFloat {
        return 50.0
    }

    func pickerView(_ pickerView: LAUPickerView, titleForColumn column: Int, forComponent component: Int) -> String? {
        return title(forColumn: column, inComponent: component)
    }

    func pickerView(_ pickerView: LAUPickerView, didChangeColumn column: Int, inComponent component: Int) {
        // Selecting a row does not call back into the delegate, so following the
        // selection across cannot come back round as a second change.
        nativePickerView.selectRow(column, inComponent: component, animated: true)
    }

    // MARK: - UIPickerViewDataSource

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return ExposureValues.allCases.count
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return values(forComponent: component).count
    }

    // MARK: - UIPickerViewDelegate

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return title(forColumn: row, inComponent: component)
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        horizontalPickerView.selectColumn(row, inComponent: component, animated: true)
    }

    // MARK: - Values

    private func values(forComponent component: Int) -> [Float] {
        guard let exposure = ExposureValues(rawValue: component) else {
            return []
        }

        return exposure.values
    }

    private func title(forColumn column: Int, inComponent component: Int) -> String? {
        let values = self.values(forComponent: component)

        guard column < values.count else {
            return nil
        }

        return String(format: "%.1f", values[column])
    }
}

#if DEBUG
#Preview("Native comparison") {
    NativeComparisonScenarioViewController()
}
#endif
