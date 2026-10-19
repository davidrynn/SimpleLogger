//
//  LogStore.swift
//  SimplerLogger
//

import Foundation
import SwiftData

enum LogError: LocalizedError {
    case emptyName
    case endBeforeStart

    var errorDescription: String? {
        switch self {
        case .emptyName: "A log needs a name."
        case .endBeforeStart: "The end time can't be before the start time."
        }
    }
}

/// Every change to logs and entries goes through here, on iPhone and watch alike.
@MainActor
struct LogStore {
    let context: ModelContext

    // MARK: Logs

    @discardableResult
    func createLog(named name: String, usesIntervals: Bool) throws -> Log {
        let name = try validated(name)
        let existing = try context.fetch(FetchDescriptor<Log>())
        let nextIndex = (existing.map(\.sortIndex).max() ?? -1) + 1
        let log = Log(name: name, usesIntervals: usesIntervals, sortIndex: nextIndex)
        context.insert(log)
        try context.save()
        return log
    }

    func update(_ log: Log, name: String, usesIntervals: Bool) throws {
        log.name = try validated(name)
        if log.usesIntervals && !usesIntervals {
            stopRunningEntries(in: log, at: .now)
        }
        log.usesIntervals = usesIntervals
        try context.save()
    }

    /// Deletes the log and, through the cascade rule, all of its entries.
    func delete(_ log: Log) throws {
        context.delete(log)
        try context.save()
    }

    /// Reorders `logs` (in their displayed order) the way `onMove` describes.
    func moveLogs(_ logs: [Log], fromOffsets source: IndexSet, toOffset destination: Int) throws {
        var reordered = logs
        reordered.move(fromOffsets: source, toOffset: destination)
        for (index, log) in reordered.enumerated() where log.sortIndex != index {
            log.sortIndex = index
        }
        try context.save()
    }

    // MARK: Entries

    /// The single button on every log: stop the running interval, start one, or add a tap entry.
    @discardableResult
    func primaryAction(for log: Log, at date: Date = .now) throws -> LogEntry? {
        if log.isRunning {
            try stopInterval(in: log, at: date)
            return nil
        }
        return log.usesIntervals ? try startInterval(in: log, at: date) : try addEntry(to: log, at: date)
    }

    @discardableResult
    func addEntry(to log: Log, at date: Date = .now) throws -> LogEntry {
        try insertEntry(in: log, start: date, isInterval: false)
    }

    /// Starts an interval, or returns the one already running.
    @discardableResult
    func startInterval(in log: Log, at date: Date = .now) throws -> LogEntry {
        if let running = log.runningEntry { return running }
        return try insertEntry(in: log, start: date, isInterval: true)
    }

    func stopInterval(in log: Log, at date: Date = .now) throws {
        stopRunningEntries(in: log, at: date)
        try context.save()
    }

    func update(_ entry: LogEntry, start: Date, end: Date?, note: String) throws {
        if let end, end < start { throw LogError.endBeforeStart }
        entry.start = start
        entry.end = end
        entry.note = note
        try context.save()
    }

    func delete(_ entries: [LogEntry]) throws {
        entries.forEach(context.delete)
        try context.save()
    }

    // MARK: Private

    private func insertEntry(in log: Log, start: Date, isInterval: Bool) throws -> LogEntry {
        let entry = LogEntry(start: start, isInterval: isInterval)
        context.insert(entry)
        entry.log = log
        try context.save()
        return entry
    }

    /// Ends every running interval; two synced devices could each have started one.
    private func stopRunningEntries(in log: Log, at date: Date) {
        for entry in log.entries ?? [] where entry.isRunning {
            entry.end = max(date, entry.start)
        }
    }

    private func validated(_ name: String) throws -> String {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw LogError.emptyName }
        return trimmed
    }
}

#if DEBUG
extension LogStore {
    /// A few logs with history, for looking at screens (launch with `-SeedSampleData`).
    func seedSampleData(now: Date = .now) throws {
        let water = try createLog(named: "Water plants", usesIntervals: false)
        for hoursAgo in [26.0, 3, 1] { try addEntry(to: water, at: now.addingTimeInterval(-hoursAgo * 3_600)) }

        let reading = try createLog(named: "Reading", usesIntervals: true)
        try startInterval(in: reading, at: now.addingTimeInterval(-5 * 3_600))
        try stopInterval(in: reading, at: now.addingTimeInterval(-4.5 * 3_600))
        try startInterval(in: reading, at: now.addingTimeInterval(-12 * 60))

        let vitamins = try createLog(named: "Took vitamins", usesIntervals: false)
        try addEntry(to: vitamins, at: now.addingTimeInterval(-25 * 3_600))

        let walk = try createLog(named: "Walk", usesIntervals: true)
        try startInterval(in: walk, at: now.addingTimeInterval(-28 * 3_600))
        try stopInterval(in: walk, at: now.addingTimeInterval(-27.25 * 3_600))
    }
}
#endif
