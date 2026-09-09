//
//  CustomColumnViewsScenarioViewController.swift
//  HorizontalPicker
//

import UIKit
import HorizontalPicker

/// Columns the delegate draws itself, rather than handing over a title for the
/// picker to draw.
///
/// A supplied view is asked for once, up front, and its width is what the column
/// is laid out at — so it has to arrive already sized. These are pills wide
/// enough to show that the layout follows the view rather than the text.
final class CustomColumnViewsScenarioViewController: ScenarioViewController,
                                                     LAUPickerViewDataSource,
                                                     LAUPickerViewDelegate {

    private static let componentHeight: CGFloat = 50.0

    private let titles = ExposureValues.aperture.titles

    private let picker = LAUPickerView()

    override func viewDidLoad() {
        super.viewDidLoad()

        picker.dataSource = self
        picker.delegate = self
        picker.hidesUnselectedColumns = false

        add(picker, height: Self.componentHeight)
        addNote("Every column is a view the delegate built — a tinted pill, sized to its own text. The column widths follow the pills, not the titles.")
    }

    // MARK: - LAUPickerViewDataSource

    func numberOfComponents(in pickerView: LAUPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: LAUPickerView, numberOfColumnsInComponent component: Int) -> Int {
        return titles.count
    }

    // MARK: - LAUPickerViewDelegate

    func pickerView(_ pickerView: LAUPickerView, heightForComponent component: Int) -> CGFloat {
        return Self.componentHeight
    }

    func pickerView(_ pickerView: LAUPickerView, viewForColumn column: Int, forComponent component: Int, reusingView view: UIView?) -> UIView? {
        return makePill(title: titles[column],
                        tint: column.isMultiple(of: 2) ? .systemIndigo : .systemTeal)
    }

    // MARK: - Columns

    private func makePill(title: String, tint: UIColor) -> UIView {
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 17.0, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        label.sizeToFit()

        let pill = UIView(frame: CGRect(x: 0.0, y: 0.0, width: label.bounds.width + 28.0, height: 32.0))
        pill.backgroundColor = tint
        pill.layer.cornerRadius = pill.bounds.height / 2.0
        label.frame = pill.bounds
        pill.addSubview(label)

        // The column is as tall as the component, with the pill centred in it.
        let container = UIView(frame: CGRect(x: 0.0, y: 0.0, width: pill.bounds.width, height: Self.componentHeight))
        pill.frame.origin.y = (container.bounds.height - pill.bounds.height) / 2.0
        container.addSubview(pill)

        return container
    }
}

#if DEBUG
#Preview("Custom column views") {
    CustomColumnViewsScenarioViewController()
}
#endif
