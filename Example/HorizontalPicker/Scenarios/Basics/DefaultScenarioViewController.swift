//
//  DefaultScenarioViewController.swift
//  HorizontalPicker
//

import UIKit
import HorizontalPicker

/// The picker as it comes: three components of titles and nothing else set.
final class DefaultScenarioViewController: ScenarioViewController {

    private let source = TitlesSource(components: ExposureValues.allTitles)

    private let selectionLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()

        let picker = LAUPickerView()
        picker.dataSource = source
        picker.delegate = source

        source.onChange = { [weak self] _, _ in
            self?.showSelection(of: picker)
        }

        add(picker, height: source.pickerHeight)

        selectionLabel.numberOfLines = 0
        selectionLabel.font = .preferredFont(forTextStyle: .footnote)
        selectionLabel.textColor = .secondaryLabel
        add(selectionLabel)

        showSelection(of: picker)
    }

    private func showSelection(of picker: LAUPickerView) {
        let selected = (0..<picker.numberOfComponents).map { component in
            String(picker.selectedColumn(inComponent: component))
        }

        selectionLabel.text = "Selected columns: \(selected.joined(separator: ", "))"
    }
}

#if DEBUG
#Preview("Default") {
    DefaultScenarioViewController()
}
#endif
