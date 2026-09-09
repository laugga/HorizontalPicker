//
//  ReloadDataScenarioViewController.swift
//  HorizontalPicker
//

import UIKit
import HorizontalPicker

/// Columns that arrive, change and go away after the picker already exists.
///
/// The picker starts with nothing in it, which is what a screen waiting on a
/// network call looks like. Each button swaps the data underneath and calls
/// `reloadData()`.
final class ReloadDataScenarioViewController: ScenarioViewController {

    private let source = TitlesSource(components: [[]])

    private let picker = LAUPickerView()

    override func viewDidLoad() {
        super.viewDidLoad()

        picker.dataSource = source
        picker.delegate = source

        add(picker, height: source.pickerHeight)

        let buttons = UIStackView(arrangedSubviews: [
            makeButton(title: "Apertures") { [weak self] in
                self?.reload(with: ExposureValues.aperture.titles)
            },
            makeButton(title: "ISO speeds") { [weak self] in
                self?.reload(with: ExposureValues.isoSpeed.titles)
            },
            makeButton(title: "Clear") { [weak self] in
                self?.reload(with: [])
            }
        ])
        buttons.axis = .horizontal
        buttons.distribution = .fillEqually
        buttons.spacing = 8

        add(buttons)
        addNote("The picker is created empty. Each button replaces the columns and calls reloadData().")
    }

    private func reload(with titles: [String]) {
        source.components = [titles]
        picker.reloadData()
    }
}

#if DEBUG
#Preview("Reload data") {
    ReloadDataScenarioViewController()
}
#endif
