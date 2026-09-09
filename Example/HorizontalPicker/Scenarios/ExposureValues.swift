//
//  ExposureValues.swift
//  HorizontalPicker
//

import Foundation

/// The three exposure scales the example has always been built around — the
/// same values the picker shows in the Lightmate camera it was written for.
enum ExposureValues: Int, CaseIterable {

    case aperture, shutterSpeed, isoSpeed

    var values: [Float] {
        switch self {
        case .aperture:
            return [ 1.0, 1.1, 1.2, 1.4, 1.6, 1.8, 2, 2.2, 2.5, 2.8, 3.2, 3.5, 4, 4.5, 4.7, 5.0, 5.6, 6.3, 7.1, 8, 9, 10, 11, 13, 14, 16, 18, 20, 22 ]
        case .shutterSpeed:
            return [ 1, 1.3, 1.6, 2, 2.5, 3, 4, 5, 6, 8, 10, 13, 15, 20, 25, 30, 40, 50, 60, 80, 100, 125, 160, 200, 250, 320, 400, 500, 640, 800, 1000, 1250, 1600, 2000, 2500, 3200, 4000 ]
        case .isoSpeed:
            return [ 50, 64, 80, 100, 125, 160, 200, 250, 320, 400, 500, 640, 800, 1000, 1250, 1600, 2000, 2500 ]
        }
    }

    var titles: [String] {
        return values.map { String(format: "%.1f", $0) }
    }

    /// The titles of every component, in component order.
    static var allTitles: [[String]] {
        return allCases.map { $0.titles }
    }
}
