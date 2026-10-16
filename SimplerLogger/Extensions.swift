//
//  Extensions.swift
//  SimplerLogger
//
//  Created by David Rynn on 5/23/22.
//

import Foundation

extension DateComponentsFormatter {
    static let duration: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.day, .hour, .minute, .second]
        return formatter
    }()
}

extension LogEntry {
    var durationText: String? {
        duration.flatMap { DateComponentsFormatter.duration.string(from: $0) }
    }
}
