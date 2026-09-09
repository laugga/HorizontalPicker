//
//  UnselectedColumnsScenarioViewController.swift
//  HorizontalPicker
//

import UIKit
import HorizontalPicker

/// `hidesUnselectedColumns`, turned on and off while the picker is running.
///
/// On — the default — the picker shows only the selected column once it settles,
/// and the rest fade back in while it is being dragged. Off, every column stays
/// on screen, which is how the original example was configured.
final class UnselectedColumnsScenarioViewController: ScenarioViewController {

    private let source = TitlesSource(components: [ExposureValues.shutterSpeed.titles])

    private let picker = LAUPickerView()

    override func viewDidLoad() {
        super.viewDidLoad()

        picker.dataSource = source
        picker.delegate = source

        add(picker, height: source.pickerHeight)

        let toggle = UISwitch()
        toggle.isOn = picker.hidesUnselectedColumns
        toggle.addAction(UIAction { [weak self, weak toggle] _ in
            self?.picker.hidesUnselectedColumns = toggle?.isOn ?? true
        }, for: .valueChanged)

        let label = UILabel()
        label.text = "Hide unselected columns"
        label.font = .preferredFont(forTextStyle: .body)

        let row = UIStackView(arrangedSubviews: [label, toggle])
        row.axis = .horizontal
        row.spacing = 12
        row.alignment = .center

        add(row)
        addNote("With it on, the unselected columns fade out once the picker settles and come back while it is dragged.")
    }
}

#if DEBUG
#Preview("Unselected columns") {
    UnselectedColumnsScenarioViewController()
}
#endif
