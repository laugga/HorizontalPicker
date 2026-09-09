//
//  Catalog.swift
//  HorizontalPicker
//

import Foundation

/// Everything the reviewer can open, in the order it is listed.
///
/// The catalog holds the index and nothing else — each entry hands back a
/// scenario that sets itself up.
enum Catalog {

    static let sections: [CatalogSection] = [

        CatalogSection(title: "Basics", scenarios: [
            CatalogScenario(
                title: "Default",
                description: "Three components of titles, nothing configured."
            ) {
                DefaultScenarioViewController()
            },
            CatalogScenario(
                title: "Initial Selection",
                description: "Opens with a column already selected in each component."
            ) {
                InitialSelectionScenarioViewController()
            }
        ]),

        CatalogSection(title: "Layout", scenarios: [
            CatalogScenario(
                title: "Variable Width",
                description: "Columns of very different widths, each laid out at its natural size."
            ) {
                VariableWidthScenarioViewController()
            },
            CatalogScenario(
                title: "Selection Alignment",
                description: "Moves the selection indicator to the left, the centre and the right."
            ) {
                SelectionAlignmentScenarioViewController()
            }
        ]),

        CatalogSection(title: "Data", scenarios: [
            CatalogScenario(
                title: "Empty Data",
                description: "A component with no columns, alongside one that has them."
            ) {
                EmptyDataScenarioViewController()
            },
            CatalogScenario(
                title: "Reload Data",
                description: "Rows arrive, change and go away after the picker already exists."
            ) {
                ReloadDataScenarioViewController()
            },
            CatalogScenario(
                title: "Large Dataset",
                description: "Five thousand columns in one component."
            ) {
                LargeDatasetScenarioViewController()
            }
        ]),

        CatalogSection(title: "Interaction", scenarios: [
            CatalogScenario(
                title: "Native Comparison",
                description: "The same exposure values in this picker and in UIPickerView, kept in step both ways."
            ) {
                NativeComparisonScenarioViewController()
            },
            CatalogScenario(
                title: "Show and Hide Components",
                description: "The component-swap animation, which has no UIPickerView counterpart."
            ) {
                ShowHideComponentsScenarioViewController()
            }
        ]),

        CatalogSection(title: "Customization", scenarios: [
            CatalogScenario(
                title: "Custom Column Views",
                description: "Columns the delegate draws itself instead of handing over a title."
            ) {
                CustomColumnViewsScenarioViewController()
            },
            CatalogScenario(
                title: "Unselected Columns",
                description: "Turns the fading of unselected columns on and off while it is running."
            ) {
                UnselectedColumnsScenarioViewController()
            }
        ]),

        CatalogSection(title: "Regressions", scenarios: [
            CatalogScenario(
                title: "Recycled Column Views",
                description: "LM-603. Drag back and forth in small steps; no column should go blank."
            ) {
                RecycledColumnViewsScenarioViewController()
            },
            CatalogScenario(
                title: "Selection Highlight",
                description: "LM-601. Walk the selection along; every column should stay drawn the same."
            ) {
                SelectionHighlightScenarioViewController()
            }
        ])
    ]
}
