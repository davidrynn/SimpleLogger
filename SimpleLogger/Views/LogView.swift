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
                ForEach(log?.entries ?? []) { entry in
                    VStack {
                        Text(entry.startDate, formatter: formatter)
                        if let endDate = entry.endDate {
                            Text(endDate, formatter: formatter)
                        }
                    }
                }
                .onDelete(perform: delete)
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
    
    func delete(_ offsets: IndexSet) {
        //Get ids from non-CoreData object
        let entryIdsToDelete = offsets.compactMap { index in
            return log?.entries[index].id
        }
        //Get coredata objects based on ids
        let entrySetToDelete = log?.entryEntities?.filter { item in
            guard let entry = item as? EntryEntity else { return false }
            return entryIdsToDelete.contains(where: { $0 == entry.id })
            
        }
        if let entrySetToDelete = entrySetToDelete {
            let entrySet = NSSet(array: entrySetToDelete)
            log?.removeFromEntryEntities(entrySet)
        }
        save()
    }
}
