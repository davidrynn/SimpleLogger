//
//  LogViewModel.swift
//  SimplerLogger
//
//  Created by David Rynn on 4/7/24.
//

import Foundation
import CoreData

class LogViewModel: ObservableObject {
    let log: LogEntity
    @Published var currentEntry: EntryEntity?
    @Published var started: Bool
    @Published var name: String
    @Published var error: Error?
    @Published var entriesGrouping: [String: [EntryEntity]]
    @Published var startDate: Date?
    @Published var usesIntervals: Bool
    let moc: NSManagedObjectContext
    let formatter: DateFormatter
    let componentsFormatter: DateComponentsFormatter
    
    
    // MARK: Initialization
    init(log: LogEntity, moc: NSManagedObjectContext) {
        self.log = log
        self.moc = moc
        self.currentEntry = log.entryEntities?.first { item in
            if let entry = item as? EntryEntity {
                return entry.intervalStarted
            }
            return false
        } as? EntryEntity
        // current entry is either the first one that's been started or new
        self.entriesGrouping = log.createGrouping()
        if log.usesIntervals {
            self.started = true
        } else {
            self.started = false
        }
//            _currentEntry = State(initialValue: currentEntry as? EntryEntity ?? EntryEntity())
        self.usesIntervals = log.usesIntervals
        self.name = log.name ?? ""
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .long
        self.formatter = dateFormatter
        let componentsFormatter = DateComponentsFormatter()
        componentsFormatter.unitsStyle = .abbreviated
        self.componentsFormatter = componentsFormatter
        self.startDate = nil
    }
    
    func getDurationStrings(_ start: Date, end: Date) -> String {
        let duration = Calendar.current.dateComponents([.day, .hour ,.minute, .second], from: start, to: end)
        return componentsFormatter.string(from: duration) ?? "Error getting time"
    }
    
   func delete(_ entries: [EntryEntity]) {
        entries.forEach { entry in
            log.removeFromEntryEntities(entry)
        }
        save()
    }
    
    // MARK: Private Functions
    func update() {
        log.name = name
        log.usesIntervals = usesIntervals
        save()
    }
    
    func startInterval() {
        startDate = Date()
        let newEntry = createNewEntry()
        newEntry.intervalStarted = true
        currentEntry = newEntry
        log.addToEntryEntities(newEntry)
        started = true
        save()
    }
    
    
    func endInterval() {
        currentEntry?.intervalStarted = false
        currentEntry?.end = Date()
        currentEntry = nil
        save()
        started = false
    }
    
    private func createNewEntry() -> EntryEntity {
        let newEntry = EntryEntity(context: moc)
        newEntry.start = startDate ?? Date()
        newEntry.id = UUID()
        return newEntry
    }
    
    func add() {
        startDate = Date()
        let newEntry = createNewEntry()
        log.addToEntryEntities(newEntry)
        save()
    }
    
    private func save() {
        do {
            try moc.save()
            self.error = nil
            entriesGrouping = log.createGrouping()
        } catch {
            self.error = LogError.CoreDataError.save
        }
    }
    
    private func saveName() {
        log.name = name
        save()
    }

}
