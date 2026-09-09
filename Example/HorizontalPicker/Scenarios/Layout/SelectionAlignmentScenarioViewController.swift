//
//  SelectionAlignmentScenarioViewController.swift
//  HorizontalPicker
//

import UIKit
import HorizontalPicker

/// The three selection alignments, switched while the picker is running.
///
/// Switching animates: the columns and the selection are carried across rather
/// than jumping, which is the part worth watching.
final class SelectionAlignmentScenarioViewController: ScenarioViewController {

    private let source = TitlesSource(components: [ExposureValues.aperture.titles])

    private let picker = LAUPickerView()

    override func viewDidLoad() {
        super.viewDidLoad()

        picker.dataSource = source
        picker.delegate = source

        add(picker, height: source.pickerHeight)

        let control = UISegmentedControl(items: ["Left", "Center", "Right"])
        control.selectedSegmentIndex = LAUPickerSelectionAlignment.center.rawValue
        control.addAction(UIAction { [weak self, weak control] _ in
            guard let control = control,
                  let alignment = LAUPickerSelectionAlignment(rawValue: control.selectedSegmentIndex) else {
                return
            }

            self?.picker.setSelectionAlignment(alignment, animated: true)
        }, for: .valueChanged)

        add(control)
        addNote("The selection indicator moves to the edge of the component. Switching is animated, so the columns should slide rather than jump.")
    }
}

#if DEBUG
#Preview("Selection alignment") {
    SelectionAlignmentScenarioViewController()
}
#endif
