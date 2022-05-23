//
//  LogEntity+CoreDataProperties.swift
//  SimpleLogger
//
//  Created by David Rynn on 5/22/22.
//
//

import Foundation
import CoreData


extension LogEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LogEntity> {
        return NSFetchRequest<LogEntity>(entityName: "LogEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var usesIntervals: Bool
    @NSManaged public var name: String?
    @NSManaged public var entryEntities: NSSet?
    
    var entries: [Entry] {
        guard let entryEntities = entryEntities as? Set<EntryEntity> else {
            return []
        }
        return entryEntities.compactMap { entry in
            guard let start = entry.start, let entryId = entry.id else { return nil }
            return Entry(id: entryId, startDate: start, endDate: entry.end)
        }.sorted { a, b in
            a.startDate > b.startDate
        }
    }

}

// MARK: Generated accessors for entryEntities
extension LogEntity {

    @objc(addEntryEntitiesObject:)
    @NSManaged public func addToEntryEntities(_ value: EntryEntity)

    @objc(removeEntryEntitiesObject:)
    @NSManaged public func removeFromEntryEntities(_ value: EntryEntity)

    @objc(addEntryEntities:)
    @NSManaged public func addToEntryEntities(_ values: NSSet)

    @objc(removeEntryEntities:)
    @NSManaged public func removeFromEntryEntities(_ values: NSSet)

}

extension LogEntity : Identifiable {

}
