//
//  EntryEntity+CoreDataProperties.swift
//  SimpleLogger
//
//  Created by David Rynn on 5/22/22.
//
//

import Foundation
import CoreData


extension EntryEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EntryEntity> {
        return NSFetchRequest<EntryEntity>(entityName: "EntryEntity")
    }

    @NSManaged public var end: Date?
    @NSManaged public var start: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var logData: LogEntity?

}

extension EntryEntity : Identifiable, Comparable {
    
    public static func < (lhs: EntryEntity, rhs: EntryEntity) -> Bool {
        if let lhsStart = lhs.start, let rhsStart = rhs.start {
            return lhsStart < rhsStart
        }
        return false
    }

}

extension DateComponents: Comparable {
    public static func < (lhs: DateComponents, rhs: DateComponents) -> Bool {
                if let lhsDay = lhs.day, let rhsDay = rhs.day {
                    return lhsDay < rhsDay
                }
        return false
    }
    
    
}
