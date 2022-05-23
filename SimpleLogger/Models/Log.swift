//
//  Log.swift
//  SimpleLogger
//
//  Created by David Rynn on 5/22/22.
//

import Foundation

struct Log: Identifiable {
    let id: UUID
    var entries: [Entry]
    var name: String
    let usesInterval: Bool
}
