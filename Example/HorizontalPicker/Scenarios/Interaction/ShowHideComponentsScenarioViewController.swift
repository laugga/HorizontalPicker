//
//  ShowHideComponentsScenarioViewController.swift
//  HorizontalPicker
//

import UIKit
import HorizontalPicker

/// `showComponent(_:andHideComponent:animated:)`, the one public method with no
/// `UIPickerView` counterpart.
///
/// It scales one component out while the other comes in, and the scale it uses
/// is the ratio of the two component heights — so the two here are deliberately
/// different heights, which is where the animation is worth looking at. LM-601
/// left open whether this method should stay; this is the screen to judge that
/// on.
final class ShowHideComponentsScenarioViewController: ScenarioViewController,
                                                      LAUPickerViewDataSource,
                                                      LAUPickerViewDelegate {

    private static let componentHeights: [CGFloat] = [90.0, 50.0]

    private let components = [ExposureValues.aperture.titles, ExposureValues.isoSpeed.titles]

    private let picker = LAUPickerView()

    override func viewDidLoad() {
        super.viewDidLoad()

        picker.dataSource = self
        picker.delegate = self

        add(picker, height: Self.componentHeights.reduce(0, +))

        let buttons = UIStackView(arrangedSubviews: [
            makeButton(title: "Show apertures") { [weak self] in
                self?.picker.showComponent(0, andHideComponent: 1, animated: true)
            },
            makeButton(title: "Show ISO speeds") { [weak self] in
                self?.picker.showComponent(1, andHideComponent: 0, animated: true)
            }
        ])
        buttons.axis = .horizontal
        buttons.distribution = .fillEqually
        buttons.spacing = 8

        add(buttons)
        addNote("Both components are on screen to begin with. Each button animates one in and the other out.")
    }

    // MARK: - LAUPickerViewDataSource

    func numberOfComponents(in pickerView: LAUPickerView) -> Int {
        return components.count
    }

    func pickerView(_ pickerView: LAUPickerView, numberOfColumnsInComponent component: Int) -> Int {
        return components[component].count
    }

    // MARK: - LAUPickerViewDelegate

    func pickerView(_ pickerView: LAUPickerView, heightForComponent component: Int) -> CGFloat {
        return Self.componentHeights[component]
    }

    func pickerView(_ pickerView: LAUPickerView, topSpaceForComponent component: Int) -> CGFloat {
        return Self.componentHeights.prefix(component).reduce(0, +)
    }

    func pickerView(_ pickerView: LAUPickerView, titleForColumn column: Int, forComponent component: Int) -> String? {
        return components[component][column]
    }
}

#if DEBUG
#Preview("Show and hide components") {
    ShowHideComponentsScenarioViewController()
}
#endif
