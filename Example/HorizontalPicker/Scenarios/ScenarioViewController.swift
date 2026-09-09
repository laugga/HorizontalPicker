//
//  ScenarioViewController.swift
//  HorizontalPicker
//

import UIKit

/// The frame every scenario is hung on: a vertical run of a picker and whatever
/// controls that scenario needs to drive it.
///
/// It exists because thirteen scenarios would otherwise repeat the same six
/// lines of Auto Layout. It does nothing to the picker itself — each scenario
/// still builds and configures its own.
class ScenarioViewController: UIViewController {

    private let stack = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        stack.axis = .vertical
        stack.spacing = 24
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        let safeArea = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 24),
            stack.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: safeArea.bottomAnchor, constant: -24)
        ])
    }

    /// Adds a view of a fixed height below whatever is already there — a
    /// picker, mostly, which has no size of its own to be laid out at.
    func add(_ subview: UIView, height: CGFloat) {
        add(subview)

        subview.heightAnchor.constraint(equalToConstant: height).isActive = true
    }

    /// Adds a control, a label, or anything else below whatever is already there.
    func add(_ subview: UIView) {
        stack.addArrangedSubview(subview)
    }

    /// Adds the line telling the reviewer what to do with the scenario, for the
    /// ones that are not self-evident.
    func addNote(_ text: String) {
        let label = UILabel()
        label.text = text
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: .footnote)
        label.textColor = .secondaryLabel

        add(label)
    }

    /// A button wired straight to a closure, for the scenarios driven by one.
    func makeButton(title: String, handler: @escaping () -> Void) -> UIButton {
        var configuration = UIButton.Configuration.bordered()
        configuration.title = title

        return UIButton(configuration: configuration, primaryAction: UIAction { _ in handler() })
    }
}
