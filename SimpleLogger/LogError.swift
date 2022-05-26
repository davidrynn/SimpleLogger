//
//  LogError.swift
//  SimpleLogger
//
//  Created by David Rynn on 5/25/22.
//

import Foundation

enum LogError {
    enum CoreDataError: Error {
        case delete, save, fetch, update
    }
    
    enum InvalidData: Error {
        case id, noLog, invalidEntity
    }
    
}
