//
//  LogView.swift
//  SimplerLogger
//
//  Created by David Rynn on 5/22/22.
//

import SwiftUI

struct LogView: View {
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var dataController: DataController
    @ObservedObject var viewModel: LogViewModel
//    @ObservedObject var log: LogEntity
    @State var presentingSheet = false
    var animation: Animation {
        if started {
            return Animation.linear(duration: 1).repeatForever()
        } else {
            return Animation.default
        }
    }
    @State var started = false
//    let formatter: DateFormatter
//    let componentsFormatter: DateComponentsFormatter
//    @State var currentEntry: EntryEntity
//    @State var usesIntervals: Bool
//    @State var name: String
    @State var startDate: Date = Date()
    @State var stopDate: Date = Date()
    @State var error: Error?
    var buttonText: String {
        if started {
            return "Stop"
        } else if viewModel.usesIntervals {
            return "Start"
        }
        return "Add"
    }
    
    init(viewModel: LogViewModel) {
        self.viewModel = viewModel
//            _log = State(initialValue: log)
//        let currentEntry = log.entryEntities?.first { item in
//            if let entry = item as? EntryEntity {
//                return entry.intervalStarted
//            }
//            return false
//        }
//        // current entry is either the first one that's been started or new
//        _currentEntry = State(initialValue: (currentEntry as? EntryEntity) ?? EntryEntity())
//        if let _ = currentEntry, log.usesIntervals {
//            _started = State(initialValue: true)
//        } else {
//            _started = State(initialValue: false)
//        }
////            _currentEntry = State(initialValue: currentEntry as? EntryEntity ?? EntryEntity())
//            _usesIntervals = State(initialValue: log.usesIntervals)
//        _name = State(initialValue: log.name ?? "")
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateStyle = .long
//        dateFormatter.timeStyle = .long
//        self.formatter = dateFormatter
//        let componentsFormatter = DateComponentsFormatter()
//        componentsFormatter.unitsStyle = .abbreviated
//        self.componentsFormatter = componentsFormatter
    }
    
    var body: some View {
        VStack {
            if error != nil {
                Text("Error: \(error.debugDescription)")
            }
            
            List {
                ForEach(viewModel.entriesGrouping.sorted(by: { $0.key > $1.key }), id: \.key) { key, entries in
                    Section(header: Text("\(key)     count: \(entries.count)")) {
                        let sorted = entries.sorted(by: { $0.start ?? Date() > $1.start ?? Date() })
                        ForEach(sorted, id: \.self) { entry in
                            NavigationLink(destination: EntryDetailsView(entry: entry), label:{
                                VStack {
                                    if let date = entry.start {
                                        Text(date, formatter: viewModel.formatter)
                                        if let endDate = entry.end {
                                            Text(viewModel.getDurationStrings(date, end: endDate))
                                            Text(endDate, formatter: viewModel.formatter)
                                        }
                                    }
                                }
                            })
                        }
                        .onDelete(perform: { offsets in
                            let entriesToDelete = offsets.compactMap { index in
                                return sorted[index]
                            }
                            viewModel.delete(entriesToDelete)
                        })
                    }
                }
            }
            
            Button {
                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                impactMed.impactOccurred()
                startDate = Date()
                if viewModel.usesIntervals && !started {
                    viewModel.startInterval()
                    return
                } else if started {
                    viewModel.endInterval()
                    return
                }
                viewModel.add()
            } label: {
                Text(buttonText)
            }
            .scaleEffect(started ? 0.9 : 1.0)
            .opacity(started ? 0.5 : 1.0)
            .animation(animation, value: started)
            .buttonStyle(.bordered)
            .navigationBarTitle(viewModel.name, displayMode: .automatic)
            .toolbar {
                ToolbarItemGroup() {
                    Button("Edit") {
                        presentingSheet = true
                    }
                    .sheet(isPresented: $presentingSheet, content: {
                        NavigationView {
                            UpdateLogView(name: $viewModel.name, useIntervals: $viewModel.usesIntervals)
                        }
                    })
                    .onChange(of: viewModel.usesIntervals) { _ in
                        viewModel.update()
                    }
                    .onChange(of: viewModel.name) { _ in
                        viewModel.update()
                    }
                    .toggleStyle(.switch)
                }
            }
        }
        
    }
/*
    private func update() {
        log.name = name
        log.usesIntervals = usesIntervals
        save()
    }
    
    private func startInterval() {
        let newEntry = createNewEntry()
        newEntry.intervalStarted = true
        currentEntry = newEntry
        log.addToEntryEntities(newEntry)
        started = true
        save()
    }
    
    private func getDurationStrings(_ start: Date, end: Date) -> String {
        let duration = Calendar.current.dateComponents([.day, .hour ,.minute, .second], from: start, to: end)
        return componentsFormatter.string(from: duration) ?? "Error getting time"
    }
    
    private func endInterval() {
        currentEntry.intervalStarted = false
        currentEntry.end = Date()
        save()
        started = false
    }
    
    private func createNewEntry() -> EntryEntity {
        let newEntry = EntryEntity(context: moc)
        newEntry.start = startDate
        newEntry.id = UUID()
        return newEntry
    }
    
    private func add() {
        let newEntry = createNewEntry()
        log.addToEntryEntities(newEntry)
        save()
    }
    
    private func save() {
        do {
            try moc.save()
            self.error = nil
        } catch {
            self.error = LogError.CoreDataError.save
        }
    }
    
    private func delete(_ entries: [EntryEntity]) {
        entries.forEach { entry in
            log.removeFromEntryEntities(entry)
        }
        save()
    }
    
    private func saveName() {
        log.name = name
        save()
    }
    */
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
            year = "no year"
        }
        
        return "\(month)-\(day)-\(year)"
    }
}
