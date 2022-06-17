//
//  DataController.swift
//  SimpleLogger
//
//  Created by David Rynn on 5/22/22.
//

import CoreData
import Foundation
import SwiftUI

class DataController: ObservableObject {
    let container = NSPersistentContainer(name: "SimpleLogger")
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \LogEntity.index, ascending: true)],
        animation: .default)
    private var logs: FetchedResults<LogEntity>
//    @Published var logs: [LogEntity]
//    @Published var dataError: Error?
    
    init() {
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Failed to load data: \(error.localizedDescription)")
            }
        }
//        do {
//            let request = NSFetchRequest<LogEntity>(entityName: "LogEntity")
//            try self.logs = container.viewContext.fetch(request)
//        } catch {
//            self.logs = []
//            self.dataError = error
//        }
    }
    
    func save() throws {
        try container.viewContext.save()
    }
    
    func createNewLog(_ name: String) -> LogEntity {
        let newLog = LogEntity(context: container.viewContext)
        newLog.id = UUID()
        newLog.name = name
        return newLog
    }
    
    func addEntry(_ logEntity: LogEntity, startInterval: Bool) throws {
        let newEntry = EntryEntity(context: container.viewContext)
        newEntry.id = UUID()
        newEntry.start = Date()
        newEntry.intervalStarted = startInterval
        logEntity.addToEntryEntities(newEntry)
        try save()
    }
    
    func updateEntry(_ logEntity: LogEntity, startInterval: Bool) throws {
        
    }
    
    func deletefromLog(_ log: LogEntity, entries: [EntryEntity]) throws {
//        entries.forEach { entry in
//            log.removeFromEntryEntities(entry)
//        }
//        try save()
    }
    
    
  
}
