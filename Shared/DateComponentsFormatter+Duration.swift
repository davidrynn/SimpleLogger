//
//  DateComponentsFormatter+Duration.swift
//  SimplerLogger
//
//  Created by David Rynn on 5/23/22.
//

import Foundation

extension DateComponentsFormatter {
    /// "1h 12m", "45s": the two largest units, abbreviated.
    static let duration: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.day, .hour, .minute, .second]
        formatter.maximumUnitCount = 2
        return formatter
    }()

    /// `interval` formatted with `duration`, or "" if it can't be formatted.
    static func durationText(_ interval: TimeInterval) -> String {
        duration.string(from: interval) ?? ""
    }
}
