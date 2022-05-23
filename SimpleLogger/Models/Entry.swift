//
//  Entry.swift
//  SimpleLogger
//
//  Created by David Rynn on 5/22/22.
//

import Foundation

struct Entry: Identifiable {
    let id: UUID
    let startDate: Date
    let endDate: Date?
}
