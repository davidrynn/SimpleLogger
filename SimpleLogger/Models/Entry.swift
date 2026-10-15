//
//  Entry.swift
//  SimplerLogger
//
//  Created by David Rynn on 5/22/22.
//

import Foundation

struct Entry: Identifiable {
    let id: UUID
    let startDate: Date
    var endDate: Date?
    var intervalStarted: Bool
}
