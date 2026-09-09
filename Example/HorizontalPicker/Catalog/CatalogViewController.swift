//
//  CatalogViewController.swift
//  HorizontalPicker
//

import UIKit

/// The index of the example app: every scenario a reviewer can open, grouped
/// into sections.
final class CatalogViewController: UITableViewController {

    private let sections = Catalog.sections

    init() {
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "HorizontalPicker"
        navigationController?.navigationBar.prefersLargeTitles = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Self.cellIdentifier)
    }

    // MARK: - UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].scenarios.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.cellIdentifier, for: indexPath)
        let scenario = self.scenario(at: indexPath)

        var content = cell.defaultContentConfiguration()
        content.text = scenario.title
        content.secondaryText = scenario.description
        content.secondaryTextProperties.numberOfLines = 0
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator

        return cell
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let scenario = self.scenario(at: indexPath)
        let viewController = scenario.makeViewController()
        viewController.title = scenario.title

        navigationController?.pushViewController(viewController, animated: true)
    }

    // MARK: - Scenarios

    private func scenario(at indexPath: IndexPath) -> CatalogScenario {
        return sections[indexPath.section].scenarios[indexPath.row]
    }

    private static let cellIdentifier = "CatalogCell"
}

#if DEBUG
#Preview("Catalog") {
    UINavigationController(rootViewController: CatalogViewController())
}
#endif
