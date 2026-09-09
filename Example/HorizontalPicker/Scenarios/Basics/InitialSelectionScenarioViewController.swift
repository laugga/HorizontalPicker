//
//  InitialSelectionScenarioViewController.swift
//  HorizontalPicker
//

import UIKit
import HorizontalPicker

/// A picker that opens on a column other than the first one in each component.
///
/// The selection is made in `viewDidAppear`: the column the picker scrolls to is
/// placed against the width of its component, and under Auto Layout that width
/// is only settled once the view has been through a full layout pass. Selecting
/// any earlier lands on column 0.
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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard !hasSelected else {
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
