//
//  EmptyDataScenarioViewController.swift
//  HorizontalPicker
//

import UIKit
import HorizontalPicker

/// A component with no columns at all, next to one that has them.
///
/// The empty component should take up its space and do nothing — no selection,
/// no crash when it is dragged — and it should not stop its neighbour working.
final class EmptyDataScenarioViewController: ScenarioViewController {

    private let source = TitlesSource(components: [[], ExposureValues.isoSpeed.titles])

    private let selectionLabel = UILabel()

    private let picker = LAUPickerView()

    override func viewDidLoad() {
        super.viewDidLoad()

        picker.dataSource = source
        picker.delegate = source

        add(picker, height: source.pickerHeight)

        selectionLabel.numberOfLines = 0
        selectionLabel.font = .preferredFont(forTextStyle: .footnote)
        selectionLabel.textColor = .secondaryLabel
        add(selectionLabel)

        addNote("The first component has no columns. Dragging where it sits should do nothing, and the second component should still work.")

        source.onChange = { [weak self] _, _ in
            self?.showSelection()
        }

        showSelection()
    }

    private func showSelection() {
        let empty = picker.selectedColumn(inComponent: 0)
        let populated = picker.selectedColumn(inComponent: 1)

        selectionLabel.text = "Empty component reports \(empty), populated component reports \(populated)."
    }
}

#if DEBUG
#Preview("Empty data") {
    EmptyDataScenarioViewController()
}
#endif
