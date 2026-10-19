//
//  Models.swift
//  SimplerLogger
//

import Foundation
import SwiftData

// CloudKit sync requires every property to be optional or have a default,
// no unique constraints, and optional relationships.

/// Something the user tracks, such as "Water plants" or "Reading", with its history of entries.
@Model
final class Log {
    var name: String = ""
    /// True for a timer log (each tap starts or stops an interval); false for a tap log (each tap is one entry).
    var usesIntervals: Bool = false
    /// Position in the user's list of logs; lower comes first.
    var sortIndex: Int = 0
    var createdAt: Date = Date.now
    /// Optional only because CloudKit requires optional relationships; treat nil as empty.
    @Relationship(deleteRule: .cascade, inverse: \LogEntry.log)
    var entries: [LogEntry]? = []

    init(name: String, usesIntervals: Bool = false, sortIndex: Int = 0) {
        self.name = name
        self.usesIntervals = usesIntervals
        self.sortIndex = sortIndex
    }
}

/// One record in a log: a moment (tap entry) or a span of time (interval entry).
@Model
final class LogEntry {
    /// When it happened, or when the interval started.
    var start: Date = Date.now
    /// Nil for a tap entry, or for an interval that is still running.
    var end: Date?
    /// Fixed when the entry is made, so changing a log's timer setting later doesn't reinterpret old entries.
    var isInterval: Bool = false
    var note: String = ""
    /// Optional only because CloudKit requires optional relationships; every entry the app makes has a log.
    var log: Log?

    init(start: Date = .now, isInterval: Bool = false) {
        self.start = start
        self.isInterval = isInterval
    }

    /// Derived rather than stored, so it can't disagree with `end`.
    var isRunning: Bool { isInterval && end == nil }

    /// Nil for tap entries and running intervals.
    var duration: TimeInterval? { end.map { $0.timeIntervalSince(start) } }
}

extension Log {
    var entryCount: Int { entries?.count ?? 0 }

    /// The interval in progress, if any. Normally there's at most one, but two synced devices can each start one.
    var runningEntry: LogEntry? { entries?.first(where: \.isRunning) }

    var isRunning: Bool { runningEntry != nil }

    var latestEntry: LogEntry? { entries?.max { $0.start < $1.start } }

    /// Entries that started on the same calendar day as `date`.
    func entries(onSameDayAs date: Date, calendar: Calendar = .current) -> [LogEntry] {
        (entries ?? []).filter { calendar.isDate($0.start, inSameDayAs: date) }
    }

    /// Entries grouped by calendar day: newest day first, newest entry first within a day.
    func entriesByDay(calendar: Calendar = .current) -> [(day: Date, entries: [LogEntry])] {
        let groups = Dictionary(grouping: entries ?? []) { calendar.startOfDay(for: $0.start) }
        return groups
            .map { (day: $0.key, entries: $0.value.sorted { $0.start > $1.start }) }
            .sorted { $0.day > $1.day }
    }
}

extension Sequence<LogEntry> {
    /// Total time of the finished intervals; running and tap entries add nothing.
    var totalDuration: TimeInterval { compactMap(\.duration).reduce(0, +) }
}

extension ModelContainer {
    /// The app's container. Syncs through CloudKit when the iCloud entitlement is present.
    /// - Parameter inMemory: Keeps everything in memory and turns off CloudKit, for tests and sample data.
    static func simplerLogger(inMemory: Bool = false) throws -> ModelContainer {
        let schema = Schema([Log.self, LogEntry.self])
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: inMemory,
            cloudKitDatabase: inMemory ? .none : .automatic
        )
        return try ModelContainer(for: schema, configurations: configuration)
    }
}
