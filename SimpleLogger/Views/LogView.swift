//
//  LogView.swift
//  SimpleLogger
//
//  Created by David Rynn on 5/22/22.
//

import SwiftUI

struct LogView: View {
    @Environment(\.managedObjectContext) var moc
    @State var log: LogEntity?
    var logDictionary: [DateComponents : [EntryEntity]] {
        get {
            guard let dict = log?.createGrouping() else {
                return [:]
            }
            return dict
        }
    }
    let formatter: DateFormatter
    let componentsFormatter: DateComponentsFormatter
    @State var isNew: Bool
    @State var currentEntry: EntryEntity?
    @State var isEditing: Bool = false
    @State var usesIntervals: Bool
    @State var name: String
    @State var startDate: Date = Date()
    @State var stopDate: Date = Date()
    var buttonText: String {
        if usesIntervals && currentEntry != nil {
            return "Stop"
        } else if usesIntervals {
            return "Start"
        }
        return "Add"
    }
    
    init(log: LogEntity?) {
        if let log = log {
            _log = State(initialValue: log)
            let currentEntry = log.entryEntities?.first { item in
                if let entry = item as? EntryEntity {
                    return entry.intervalStarted
                }
                return false
            }
            _currentEntry = State(initialValue: currentEntry as? EntryEntity)
            _isNew = State(initialValue: false)
            _usesIntervals = State(initialValue: log.usesIntervals)
        } else {
            _isNew = State(initialValue: true)
            _usesIntervals = State(initialValue: false)
        }
        _name = State(initialValue: log?.name ?? "")
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .long
        self.formatter = dateFormatter
        let componentsFormatter = DateComponentsFormatter()
        componentsFormatter.unitsStyle = .abbreviated
        self.componentsFormatter = componentsFormatter
    }
    
    var body: some View {
        VStack {
            if isNew || isEditing {
                Form {
                    TextField("Please enter new name", text: $name) {
                        if isNew {
                            createNewLog()
                            isNew.toggle()
                        } else {
                            updateName()
                        }
                        save()
                    }
                }
            }
            
            List {
                ForEach(logDictionary.sorted(by: { $0.key > $1.key }), id: \.key) { key, entries in
                    Section(header: Text(getSectionText(key))) {
                        let sorted = entries.sorted(by: { $0.start ?? Date() > $1.start ?? Date() })
                        ForEach(sorted, id: \.self) { entry in
                            VStack {
                                if let date = entry.start {
                                    Text(date, formatter: formatter)
                                    if let endDate = entry.end {
                                        Text(getDurationStrings(date, end: endDate))
                                        Text(endDate, formatter: formatter)
                                    }
                                }
                            }
                        }
                        .onDelete(perform: { offsets in
                            let entriesToDelete = offsets.compactMap { index in
                                return sorted[index]
                            }
                            delete(entriesToDelete)
                        })
                    }
                }
            }
            
            Button {
                startDate = Date()
                if usesIntervals && currentEntry == nil {
                    startInterval()
                    return
                } else if usesIntervals && currentEntry != nil {
                    endInterval()
                    return
                }
                add()
            } label: {
                Text(currentEntry != nil && usesIntervals ? buttonText + "..." : buttonText)
                    .animation(currentEntry != nil ? .easeIn(duration: 1).repeatForever() : .default, value: currentEntry)
            }
            .buttonStyle(.bordered)
            .navigationBarTitle(name, displayMode: .automatic)
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Toggle(isOn: $usesIntervals) {
                        Text("Use Intervals")
                    }
                    .onChange(of: usesIntervals) { _ in
                        updateUseIntervals()
                    }
                    .toggleStyle(.switch)
                    Spacer()
                    Toggle(isOn: $isEditing) {
                        Text("Edit")
                    }
                    .toggleStyle(.switch)
                }
            }
        }

    }
    
    private func updateName() {
        log?.name = name
    }
    
    private func updateUseIntervals() {
        log?.usesIntervals = usesIntervals
        save()
    }
    
    private func createNewLog() {
        let newLog = LogEntity(context: moc)
        newLog.id = UUID()
        newLog.name = name
        newLog.usesIntervals = usesIntervals
        self.log = newLog
    }
    
    private func startInterval() {
        guard currentEntry == nil else {
            endInterval()
            return
        }
        let newEntry = createNewEntry()
        newEntry.intervalStarted = true
        currentEntry = newEntry
        if log == nil {
            createNewLog()
        }
        log?.addToEntryEntities(newEntry)
        save()
    }
                                             
    private func getDurationStrings(_ start: Date, end: Date) -> String {
        let duration = Calendar.current.dateComponents([.day, .hour ,.minute, .second], from: start, to: end)
        return componentsFormatter.string(from: duration) ?? "Error getting time"
    }
    
    private func endInterval() {
        guard let currentEntry = currentEntry, let _ = log else {
            return
        }
        currentEntry.intervalStarted = false
        currentEntry.end = Date()
        save()
        self.currentEntry = nil
    }
    
    private func createNewEntry() -> EntryEntity {
        let newEntry = EntryEntity(context: moc)
        newEntry.start = startDate
        newEntry.id = UUID()
        return newEntry
    }
    
    private func add() {
        let newEntry = createNewEntry()
        if log == nil {
            createNewLog()
        }
        log?.addToEntryEntities(newEntry)
        save()
    }
    
    private func save() {
        do {
            try moc.save()
        } catch {
            print(error)
        }
    }
    
    private func delete(_ entries: [EntryEntity]) {
        entries.forEach { entry in
            log?.removeFromEntryEntities(entry)
        }
        save()
    }
    
    private func saveName() {
        log?.name = name
        save()
    }
    
    private func getSectionText(_ dateComponents: DateComponents) -> String {
        let day: String
        if let keyDay = dateComponents.day {
            day = String(keyDay)
        } else {
            day = "no day"
        }
        let month: String
        if let keyMonth = dateComponents.month {
            month = String(keyMonth)
        } else {
            month = "no month"
        }
        let year: String
        if let keyYear = dateComponents.year {
            year = String(keyYear)
        } else {
            year = "no month"
        }
        
        return "\(month)-\(day)-\(year)"
    }
}
