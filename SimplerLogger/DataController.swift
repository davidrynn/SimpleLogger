//
//  DataController.swift
//  SimplerLogger
//
//  Created by David Rynn on 5/22/22.
//

import CoreData
import SwiftUI

class DataController: ObservableObject {
    let container = NSPersistentContainer(name: "SimplerLogger")
    
    init() {
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Failed to load data: \(error.localizedDescription)")
            }
        }
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
}
