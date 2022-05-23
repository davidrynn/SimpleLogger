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

extension EntryEntity : Identifiable {

}
