//
//  InitialSelectionScenarioViewController.swift
//  HorizontalPicker
//

import UIKit
import HorizontalPicker

/// A picker that opens on a column other than the first one in each component.
///
/// The selection is made once the picker has been laid out: the column it scrolls
/// to is placed against the component's width, which Auto Layout only settles
/// after `viewDidLoad`.
final class InitialSelectionScenarioViewController: ScenarioViewController {

    private static let initialColumns = [12, 20, 6]

    private let source = TitlesSource(components: ExposureValues.allTitles)

    private let picker = LAUPickerView()

    private var hasSelected = false

    override func viewDidLoad() {
        super.viewDidLoad()

        picker.dataSource = source
        picker.delegate = source

        add(picker, height: source.pickerHeight)
        addNote("Opens on columns \(Self.initialColumns.map(String.init).joined(separator: ", ")) — f/4, 1/100s, ISO 200.")
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard !hasSelected, picker.bounds.width > 0 else {
            return
        }

        hasSelected = true

        for (component, column) in Self.initialColumns.enumerated() {
            picker.selectColumn(column, inComponent: component, animated: false)
        }
    }
}

#if DEBUG
#Preview("Initial selection") {
    InitialSelectionScenarioViewController()
}
#endif
