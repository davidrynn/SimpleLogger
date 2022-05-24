//
//  Extensions.swift
//  SimpleLogger
//
//  Created by David Rynn on 5/23/22.
//

import Foundation

extension EntryEntity : Comparable {
    
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
