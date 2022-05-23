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
    let isNew: Bool
    @State var usesIntervals: Bool
    @State var name: String
    @State var startDate: Date = Date()
    @State var stopDate: Date = Date()
    @State var didStart: Bool = false
    var buttonText: String {
        if usesIntervals && didStart {
            return "Stop"
        }
        if usesIntervals && !didStart {
            return "Start"
        }
        return "Add"
    }
    
    init(log: LogEntity?) {
        if let log = log {
            _log = State(initialValue: log)
            isNew = false
            _usesIntervals = State(initialValue: log.usesIntervals)
        } else {
            isNew = true
            _usesIntervals = State(initialValue: false)
        }
        _name = State(initialValue: log?.name ?? "")
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .long
        self.formatter = dateFormatter
    }
    
    var body: some View {
        VStack {
            if isNew && name.isEmpty {
                Form {
                    TextField("Please enter new name", text: $name)
                }
            }
            Button {
                startDate = Date()
                if usesIntervals && !didStart {
                    didStart = true
                    return
                }
                if usesIntervals && didStart {
                    stopDate = Date()
                }
                didStart = false
                add()
            } label: {
                Text(didStart && usesIntervals ? buttonText + "..." : buttonText)
                    .animation(didStart ? .easeIn(duration: 1).repeatForever() : .default, value: didStart)
            }
            .buttonStyle(.bordered)
            
            List {
                ForEach(logDictionary.sorted(by: { $0.key < $1.key }), id: \.key) { key, entries in
                    Section(header: Text(getSectionText(key))) {
                        let sorted = entries.sorted(by: { $0.start ?? Date() < $1.start ?? Date() })
                        ForEach(entries.sorted(by: { $0.start ?? Date() < $1.start ?? Date() }), id: \.self) { entry in
                            VStack {
                                if let date = entry.start {
                                    Text(date, formatter: formatter)
                                    if let endDate = entry.end {
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
            .navigationTitle(name)
            .toolbar {
                ToolbarItem {
                    Toggle(isOn: $usesIntervals) {
                        Text("Use Intervals")
                    }
                    .onChange(of: usesIntervals) { _ in
                        updateUseIntervals()
                    }
                    .toggleStyle(.switch)
                }
            }
        }
        
    }
    
    func updateUseIntervals() {
        log?.usesIntervals = usesIntervals
        didStart = false
        save()
    }
    
    func add() {
        let newEntry = EntryEntity(context: moc)
        newEntry.start = startDate
        newEntry.end = usesIntervals ? stopDate : nil
        newEntry.id = UUID()
        if log == nil {
            let newLog = LogEntity(context: moc)
            newLog.id = UUID()
            newLog.name = name
            newLog.usesIntervals = usesIntervals
            self.log = newLog
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
        
        return "\(month), \(day), \(year)"
    }
}
