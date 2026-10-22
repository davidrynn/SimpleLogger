//
//  Extensions.swift
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

extension LogEntry {
    /// "1h 12m" for a finished interval; nil for tap entries and running intervals.
    var durationText: String? {
        duration.map(DateComponentsFormatter.durationText)
    }

    /// "6:04 PM" for a tap, "6:04 PM – 7:16 PM" for a finished interval.
    var timeText: String {
        let startText = start.formatted(date: .omitted, time: .shortened)
        guard let end else { return startText }
        return "\(startText) – \(end.formatted(date: .omitted, time: .shortened))"
    }
}

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

extension Log {
    /// The secondary line under a counter's name in the list, such as "3 today · last 6:04 PM".
    /// `compact` drops the time, for the watch: "3 today", "Last: Yesterday".
    func summary(now: Date = .now, calendar: Calendar = .current, compact: Bool = false) -> String {
        guard let latest = latestEntry else { return String(localized: "Nothing counted yet") }
        let today = entries(onSameDayAs: now, calendar: calendar)
        let lastDay = latest.start.dayTitle(now: now, calendar: calendar)
        let lastTime = latest.start.formatted(date: .omitted, time: .shortened)
        guard !today.isEmpty else {
            return compact ? String(localized: "Last: \(lastDay)") : String(localized: "Last: \(lastDay), \(lastTime)")
        }
        if usesIntervals {
            let total = today.totalDuration
            if total > 0 { return String(localized: "\(DateComponentsFormatter.durationText(total)) today") }
        }
        return compact ? String(localized: "\(today.count) today") : String(localized: "\(today.count) today · last \(lastTime)")
    }
}

extension Log {
    /// The primary action's symbol: count, start or stop.
    var actionSymbol: String {
        if isRunning { return "stop.fill" }
        return usesIntervals ? "play.fill" : "plus"
    }

    /// The primary action as VoiceOver says it, such as "Stop Reading timer".
    var actionLabel: String {
        if isRunning { return String(localized: "Stop \(name) timer") }
        if usesIntervals { return String(localized: "Start \(name) timer") }
        return String(localized: "Count \(name)")
    }
}
