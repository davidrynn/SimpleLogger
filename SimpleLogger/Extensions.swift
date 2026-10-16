//
//  Extensions.swift
//  SimplerLogger
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
            // Entries saved with a nil start by an older bug get their own section so they can still be deleted.
            guard let start = entry.start else { return "No date" }
            let dateComp = Calendar.current.dateComponents([ .month, .day, .year], from: start)
            let dateText = String(format: "%ld-%.2ld-%.2ld", dateComp.year ?? 0, dateComp.month ?? 0, dateComp.day ?? 0)
            return dateText
        }
        return groupDic
    }
}
