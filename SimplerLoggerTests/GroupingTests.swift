//
//  GroupingTests.swift
//  SimplerLoggerTests
//

import CoreData
import Testing
@testable import SimplerLogger

@MainActor
struct GroupingTests {
    let context: NSManagedObjectContext

    init() throws {
        let container = NSPersistentContainer(name: "SimplerLogger")
        container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        var loadError: Error?
        container.loadPersistentStores { _, error in loadError = error }
        if let loadError { throw loadError }
        context = container.viewContext
    }

    @Test func entryWithoutStartDateIsGroupedInsteadOfCrashing() {
        let log = LogEntity(context: context)
        let dated = EntryEntity(context: context)
        dated.start = Date(timeIntervalSince1970: 0)
        let undated = EntryEntity(context: context)
        log.addToEntryEntities(dated)
        log.addToEntryEntities(undated)

        let grouping = log.createGrouping()

        #expect(grouping["No date"] == [undated])
        #expect(grouping.values.joined().count == 2)
    }
}
