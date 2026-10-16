//
//  LogEntity+CoreDataProperties.swift
//  SimplerLogger
//
//  Created by David Rynn on 6/3/22.
//
//

import Foundation
import CoreData


extension LogEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LogEntity> {
        return NSFetchRequest<LogEntity>(entityName: "LogEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var usesIntervals: Bool
    @NSManaged public var index: Int64
    @NSManaged public var entryEntities: NSSet?

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
