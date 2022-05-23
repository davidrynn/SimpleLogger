//
//  DataController.swift
//  SimpleLogger
//
//  Created by David Rynn on 5/22/22.
//

import CoreData
import Foundation

class DataController: ObservableObject {
    let container = NSPersistentContainer(name: "SimpleLogger")
    
    init() {
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Failed to load data: \(error.localizedDescription)")
            }
        }
    }
  
}
