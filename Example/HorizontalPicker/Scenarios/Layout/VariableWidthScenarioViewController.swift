//
//  VariableWidthScenarioViewController.swift
//  HorizontalPicker
//

import UIKit
import HorizontalPicker

/// Columns whose widths are nothing like each other.
///
/// Every column is laid out at the natural width of its own title, so the
/// spacing between them is uneven by design. What should hold is that whichever
/// column is selected comes to rest under the selection indicator, however wide
/// its neighbours are.
final class VariableWidthScenarioViewController: ScenarioViewController {

    private static let mixedWidths = [
        "1", "22", "333", "4444", "A rather long value", "5", "66",
        "Another long one", "7", "888", "9", "Longest value in the component",
        "10", "11", "12", "A", "BB", "CCC", "DDDD", "EEEEE"
    ]

    private static let evenWidths = Array(repeating: "000", count: 20)

    private let source = TitlesSource(components: [mixedWidths, evenWidths])

    override func viewDidLoad() {
        super.viewDidLoad()

        let picker = LAUPickerView()
        picker.dataSource = source
        picker.delegate = source

        // Every column stays on screen: the widths are the point, and only one
        // column at a time would show nothing to compare.
        picker.hidesUnselectedColumns = false

        add(picker, height: source.pickerHeight)
        addNote("The top component's columns are all different widths; the bottom one's are all the same. Spinning either should leave the selected column centred.")
    }
}

#if DEBUG
#Preview("Variable width") {
    VariableWidthScenarioViewController()
}
#endif
