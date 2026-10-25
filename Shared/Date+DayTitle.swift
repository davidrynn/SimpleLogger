//
//  Date+DayTitle.swift
//  SimplerLogger
//
//  Created by David Rynn on 5/23/22.
//

import Foundation

extension Date {
    /// "Today", "Yesterday", "Monday, Oct 12", or "Oct 12, 2025" outside the current year.
    func dayTitle(now: Date = .now, calendar: Calendar = .current) -> String {
        if calendar.isDate(self, inSameDayAs: now) { return String(localized: "Today") }
        if let yesterday = calendar.date(byAdding: .day, value: -1, to: now),
           calendar.isDate(self, inSameDayAs: yesterday) {
            return String(localized: "Yesterday")
        }
        if calendar.isDate(self, equalTo: now, toGranularity: .year) {
            return formatted(.dateTime.weekday(.wide).month(.abbreviated).day())
        }
        return formatted(.dateTime.month(.abbreviated).day().year())
    }
}
