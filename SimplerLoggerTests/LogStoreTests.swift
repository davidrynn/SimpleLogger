//
//  LogStoreTests.swift
//  SimplerLoggerTests
//

import Foundation
import SwiftData
import Testing
@testable import SimplerLogger

@MainActor
struct LogStoreTests {
    let container: ModelContainer
    let store: LogStore

    init() throws {
        container = try .simplerLogger(inMemory: true)
        store = LogStore(context: container.mainContext)
    }

    private func allLogs() throws -> [Log] {
        try container.mainContext.fetch(FetchDescriptor<Log>(sortBy: [SortDescriptor(\.sortIndex)]))
    }

    private func entryCount() throws -> Int {
        try container.mainContext.fetchCount(FetchDescriptor<LogEntry>())
    }

    // MARK: Logs

    @Test func newLogsAreAppendedInOrder() throws {
        try store.createLog(named: "Water plants", usesIntervals: false)
        try store.createLog(named: "Run", usesIntervals: true)
        #expect(try allLogs().map(\.name) == ["Water plants", "Run"])
        #expect(try allLogs().map(\.sortIndex) == [0, 1])
    }

    @Test func blankNamesAreRejectedAndNamesAreTrimmed() throws {
        #expect(throws: LogError.emptyName) { try store.createLog(named: "   ", usesIntervals: false) }
        let log = try store.createLog(named: "  Water  ", usesIntervals: false)
        #expect(log.name == "Water")
    }

    @Test func movingLogsRewritesSortIndices() throws {
        for name in ["A", "B", "C"] { try store.createLog(named: name, usesIntervals: false) }
        try store.moveLogs(try allLogs(), fromOffsets: IndexSet(integer: 2), toOffset: 0)
        #expect(try allLogs().map(\.name) == ["C", "A", "B"])
    }

    @Test func deletingALogDeletesItsEntries() throws {
        let log = try store.createLog(named: "Water", usesIntervals: false)
        let other = try store.createLog(named: "Run", usesIntervals: false)
        try store.addEntry(to: log)
        try store.addEntry(to: log)
        try store.addEntry(to: other)

        try store.delete(log)

        #expect(try allLogs().map(\.name) == ["Run"])
        #expect(try entryCount() == 1)
    }

    // MARK: Primary action

    @Test func tapLogAddsAnEntryStampedWithTheTime() throws {
        let log = try store.createLog(named: "Water", usesIntervals: false)
        let now = Date(timeIntervalSince1970: 1_000)
        let entry = try #require(try store.primaryAction(for: log, at: now))
        #expect(entry.start == now)
        #expect(entry.end == nil)
        #expect(!entry.isRunning)
        #expect(!log.isRunning)
        #expect(log.entryCount == 1)
    }

    @Test func intervalLogStartsThenStops() throws {
        let log = try store.createLog(named: "Run", usesIntervals: true)
        let start = Date(timeIntervalSince1970: 1_000)
        let entry = try #require(try store.primaryAction(for: log, at: start))
        #expect(log.isRunning)

        #expect(try store.primaryAction(for: log, at: start.addingTimeInterval(90)) == nil)
        #expect(!log.isRunning)
        #expect(entry.duration == 90)
        #expect(log.entryCount == 1)
    }

    @Test func startingWhileRunningReturnsTheRunningEntry() throws {
        let log = try store.createLog(named: "Run", usesIntervals: true)
        let first = try store.startInterval(in: log)
        #expect(try store.startInterval(in: log) === first)
        #expect(log.entryCount == 1)
    }

    @Test func turningOffIntervalsStopsTheRunningOne() throws {
        let log = try store.createLog(named: "Run", usesIntervals: true)
        try store.startInterval(in: log)
        try store.update(log, name: "Run", usesIntervals: false)
        #expect(!log.isRunning)
    }

    // MARK: Entries

    @Test func editingAnEntryValidatesTimes() throws {
        let log = try store.createLog(named: "Run", usesIntervals: true)
        let entry = try store.startInterval(in: log, at: Date(timeIntervalSince1970: 1_000))
        #expect(throws: LogError.endBeforeStart) {
            try store.update(entry, start: Date(timeIntervalSince1970: 1_000), end: Date(timeIntervalSince1970: 500), note: "")
        }
        try store.update(entry, start: Date(timeIntervalSince1970: 1_000), end: Date(timeIntervalSince1970: 1_600), note: "Park loop")
        #expect(entry.note == "Park loop")
        #expect(entry.duration == 600)
    }

    @Test func deletingEntriesRemovesThemFromTheLog() throws {
        let log = try store.createLog(named: "Water", usesIntervals: false)
        let entry = try store.addEntry(to: log)
        try store.addEntry(to: log)
        try store.delete([entry])
        #expect(log.entryCount == 1)
        #expect(try entryCount() == 1)
    }

    @Test func entriesAreGroupedByDayNewestFirst() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let log = try store.createLog(named: "Water", usesIntervals: false)
        let dayOne = Date(timeIntervalSince1970: 0)
        let laterDayOne = dayOne.addingTimeInterval(3_600)
        let dayTwo = dayOne.addingTimeInterval(86_400)
        for date in [dayOne, dayTwo, laterDayOne] { try store.addEntry(to: log, at: date) }

        let groups = log.entriesByDay(calendar: calendar)

        #expect(groups.map(\.day) == [dayTwo, dayOne])
        #expect(groups[1].entries.map(\.start) == [laterDayOne, dayOne])
    }
}
