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

extension DateComponentsFormatter {
    func getDurationStrings(_ start: Date, end: Date) -> String? {
        let duration = Calendar.current.dateComponents([.day, .hour ,.minute, .second], from: start, to: end)
        return self.string(from: duration)
    }
}

extension LogEntity {
    func createGrouping() -> [String: [EntryEntity]]{
        guard let entries = entryEntities, let entryArray = Array(entries) as? [EntryEntity] else { return [:] }
        let groupDic = Dictionary(grouping: entryArray) { entry -> String in
            let dateComp = Calendar.current.dateComponents([ .month, .day, .year], from: (entry.start)!)
            let dateText = String(format: "%ld-%.2ld-%.2ld", dateComp.year!, dateComp.month!, dateComp.day!)
            return dateText
        }
        return groupDic
    }
}
