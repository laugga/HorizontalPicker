//
//  TitlesSource.swift
//  HorizontalPicker
//

import UIKit
import HorizontalPicker

/// A data source and delegate over plain titles, which most scenarios need and
/// only a few go beyond.
///
/// The picker holds its data source and delegate weakly, so a scenario using
/// this has to keep hold of it.
final class TitlesSource: LAUPickerViewDataSource, LAUPickerViewDelegate {

    /// The columns of each component. Assigning new ones does not reload the
    /// picker on its own — the scenario decides when that happens.
    var components: [[String]]

    /// The height each component is laid out at.
    var componentHeight: CGFloat

    /// Called when the picker settles on a different column.
    var onChange: ((_ column: Int, _ component: Int) -> Void)?

    init(components: [[String]], componentHeight: CGFloat = 50.0) {
        self.components = components
        self.componentHeight = componentHeight
    }

    /// The height a picker showing all of these components should be given.
    var pickerHeight: CGFloat {
        return componentHeight * CGFloat(max(components.count, 1))
    }

    // MARK: - LAUPickerViewDataSource

    func numberOfComponents(in pickerView: LAUPickerView) -> Int {
        return components.count
    }

    func pickerView(_ pickerView: LAUPickerView, numberOfColumnsInComponent component: Int) -> Int {
        return components[component].count
    }

    // MARK: - LAUPickerViewDelegate

    func pickerView(_ pickerView: LAUPickerView, heightForComponent component: Int) -> CGFloat {
        return componentHeight
    }

    func pickerView(_ pickerView: LAUPickerView, titleForColumn column: Int, forComponent component: Int) -> String? {
        return components[component][column]
    }

    func pickerView(_ pickerView: LAUPickerView, didChangeColumn column: Int, inComponent component: Int) {
        onChange?(column, component)
    }
}
