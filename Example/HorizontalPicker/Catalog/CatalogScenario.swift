//
//  CatalogScenario.swift
//  HorizontalPicker
//

import UIKit

/// One entry in the catalog: a name, a line saying what it is for, and the
/// screen it opens.
struct CatalogScenario {

    let title: String

    let description: String?

    let makeViewController: () -> UIViewController

    init(title: String,
         description: String? = nil,
         makeViewController: @escaping () -> UIViewController) {
        self.title = title
        self.description = description
        self.makeViewController = makeViewController
    }
}
