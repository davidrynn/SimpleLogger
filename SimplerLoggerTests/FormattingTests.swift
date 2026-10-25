//
//  FormattingTests.swift
//  SimplerLoggerTests
//

import Foundation
import SwiftData
import Testing
@testable import SimplerLogger

@MainActor
struct FormattingTests {
    let container: ModelContainer
    let store: LogStore
    let calendar = Calendar.current
    /// Midday, so adding or subtracting an hour stays on the same day.
    let now = Calendar.current.date(from: DateComponents(year: 2026, month: 10, day: 18, hour: 12))!

    init() throws {
        container = try .simplerLogger(inMemory: true)
        store = LogStore(context: container.mainContext)
    }

    @Test func dayTitlesAreRelativeForTodayAndYesterday() {
        #expect(now.dayTitle(now: now, calendar: calendar) == "Today")
        #expect(now.addingTimeInterval(-86_400).dayTitle(now: now, calendar: calendar) == "Yesterday")
        let lastYear = calendar.date(byAdding: .year, value: -1, to: now)!
        #expect(lastYear.dayTitle(now: now, calendar: calendar).contains("2025"))
    }

    @Test func durationsShowTheTwoLargestUnits() {
        #expect(DateComponentsFormatter.durationText(4_323) == "1h 12m")
        #expect(DateComponentsFormatter.durationText(45) == "45s")
    }

    @Test func summaryForAnEmptyLog() throws {
        let log = try store.createLog(named: "Water", usesIntervals: false)
        #expect(log.summary(now: now, calendar: calendar) == "Nothing counted yet")
    }

    @Test func summaryCountsTodaysTaps() throws {
        let log = try store.createLog(named: "Water", usesIntervals: false)
        try store.addEntry(to: log, at: now.addingTimeInterval(-86_400))
        try store.addEntry(to: log, at: now.addingTimeInterval(-3_600))
        try store.addEntry(to: log, at: now)
        #expect(log.summary(now: now, calendar: calendar).hasPrefix("2 today · last "))
    }

    @Test func summaryTotalsTodaysTime() throws {
        let log = try store.createLog(named: "Reading", usesIntervals: true)
        try store.startInterval(in: log, at: now.addingTimeInterval(-3_600))
        try store.stopInterval(in: log, at: now.addingTimeInterval(-1_800))
        try store.startInterval(in: log, at: now.addingTimeInterval(-600))
        try store.stopInterval(in: log, at: now)
        #expect(log.summary(now: now, calendar: calendar) == "40m today")
    }

    @Test func summaryNamesTheLastDayWhenNothingToday() throws {
        let log = try store.createLog(named: "Water", usesIntervals: false)
        try store.addEntry(to: log, at: now.addingTimeInterval(-86_400))
        #expect(log.summary(now: now, calendar: calendar).hasPrefix("Last: Yesterday, "))
    }

    @Test func compactSummaryDropsTheTime() throws {
        let log = try store.createLog(named: "Water", usesIntervals: false)
        try store.addEntry(to: log, at: now.addingTimeInterval(-86_400))
        #expect(log.summary(now: now, calendar: calendar, compact: true) == "Last: Yesterday")
        try store.addEntry(to: log, at: now)
        #expect(log.summary(now: now, calendar: calendar, compact: true) == "1 today")
    }
}
