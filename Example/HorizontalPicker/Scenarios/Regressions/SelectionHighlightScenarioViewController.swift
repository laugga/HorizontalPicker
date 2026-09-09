//
//  SelectionHighlightScenarioViewController.swift
//  HorizontalPicker
//

import UIKit
import HorizontalPicker

/// The state behind LM-601: the selection walked far enough along a component
/// for its cells to be recycled several times over.
///
/// The picker used to draw the selected column in a bolder, larger font and
/// never take it back off, so the emphasis both stayed on a column that was no
/// longer selected and reached columns that had never been selected at all.
/// That drawing is gone; what should be visible here is one font, one size,
/// throughout — the only thing marking the selection is the opacity of its
/// neighbours.
final class SelectionHighlightScenarioViewController: ScenarioViewController {

    private static let columnCount = 120

    private let source = TitlesSource(components: [(0..<columnCount).map(String.init)])

    private let picker = LAUPickerView()

    override func viewDidLoad() {
        super.viewDidLoad()

        picker.dataSource = source
        picker.delegate = source

        // Unselected columns are left on screen, which is where the stale
        // emphasis used to be visible.
        picker.hidesUnselectedColumns = false

        add(picker, height: source.pickerHeight)

        let buttons = UIStackView(arrangedSubviews: [
            makeButton(title: "Step back") { [weak self] in
                self?.step(by: -1)
            },
            makeButton(title: "Step on") { [weak self] in
                self?.step(by: 1)
            },
            makeButton(title: "Walk to the end") { [weak self] in
                self?.walkToTheEnd()
            }
        ])
        buttons.axis = .horizontal
        buttons.distribution = .fillEqually
        buttons.spacing = 8

        add(buttons)
        addNote("Step the selection along, or walk it the whole way. Every column should be drawn in the same font and at the same size, before, during and after being selected.")
    }

    private func step(by offset: Int) {
        let column = picker.selectedColumn(inComponent: 0) + offset

        guard (0..<Self.columnCount).contains(column) else {
            return
        }

        picker.selectColumn(column, inComponent: 0, animated: true)
    }

    private func walkToTheEnd() {
        walk(from: picker.selectedColumn(inComponent: 0) + 1)
    }

    private func walk(from column: Int) {
        guard column < Self.columnCount else {
            return
        }

        picker.selectColumn(column, inComponent: 0, animated: true)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) { [weak self] in
            self?.walk(from: column + 1)
        }
    }
}

#if DEBUG
#Preview("Selection highlight") {
    SelectionHighlightScenarioViewController()
}
#endif
