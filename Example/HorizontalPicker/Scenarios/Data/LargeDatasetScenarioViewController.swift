//
//  LargeDatasetScenarioViewController.swift
//  HorizontalPicker
//

import UIKit
import HorizontalPicker

/// Five thousand columns in one component.
///
/// Worth watching for how long the screen takes to appear — every column is
/// measured up front — and whether a fast flick stays smooth once it is there.
final class LargeDatasetScenarioViewController: ScenarioViewController {

    private static let columnCount = 5_000

    private let source = TitlesSource(components: [(0..<columnCount).map(String.init)])

    private let picker = LAUPickerView()

    override func viewDidLoad() {
        super.viewDidLoad()

        picker.dataSource = source
        picker.delegate = source

        add(picker, height: source.pickerHeight)

        let jumpButtons = UIStackView(arrangedSubviews: [
            makeButton(title: "First") { [weak self] in
                self?.picker.selectColumn(0, inComponent: 0, animated: true)
            },
            makeButton(title: "Middle") { [weak self] in
                self?.picker.selectColumn(Self.columnCount / 2, inComponent: 0, animated: true)
            },
            makeButton(title: "Last") { [weak self] in
                self?.picker.selectColumn(Self.columnCount - 1, inComponent: 0, animated: true)
            }
        ])
        jumpButtons.axis = .horizontal
        jumpButtons.distribution = .fillEqually
        jumpButtons.spacing = 8

        add(jumpButtons)
        addNote("\(Self.columnCount) columns. Flick through them, and jump between the ends.")
    }
}

#if DEBUG
#Preview("Large dataset") {
    LargeDatasetScenarioViewController()
}
#endif
