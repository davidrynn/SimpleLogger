//
//  ContentView.swift
//  SimplerLoggerWatch WatchKit Extension
//
//  Created by David Rynn on 5/27/22.
//

import SwiftUI

struct MainView: View {
    
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: []) var logs: FetchedResults<LogEntity>
    @State var didStart = false
    @State var didStop = false
    @State var startTime = Date()
    @State var stopTime = Date()
    @State var animate = false
    @State var error: Error?
    
    var body: some View {
        List {
            ForEach(logs, id: \.self) { log in
                    WatchRow(name: log.name ?? "No Name") {
                        startTime = Date()
                        //if started animating, stop interval and stop animation
                        if let startedEntryEntity = log.entryEntities?.first(where: { item in
                            if let entryEntity = item as? EntryEntity {
                                return entryEntity.intervalStarted == true
                            }
                            return false
                        }) as? EntryEntity {
                            stopInterval(startedEntryEntity)
                            return false
                        }
                        // if already hasn't started but uses intervals
                        else if log.usesIntervals {
                            addEntry(log, startInterval: true)
                            return true
                        }
                        // otherwise just add entry
                        addEntry(log, startInterval: false)
                        return false
                    }
                    .onChange(of: didStart) { _ in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            didStart ? (animate = true) : (animate = false)
                        }
                    }
            }
        }
    }
    
    private func delete(at offsets: IndexSet) {
        offsets.forEach { index in
            moc.delete(logs[index])
        }
        do {
            try moc.save()
        } catch {
            self.error = LogError.CoreDataError.delete
        }
    }
    
    private func addEntry(_ logEntity: LogEntity, startInterval: Bool) {
        let newEntry = EntryEntity(context: moc)
        newEntry.id = UUID()
        newEntry.start = startTime
        newEntry.intervalStarted = startInterval
        logEntity.addToEntryEntities(newEntry)
        save()
    }
    
    private func stopInterval(_ startedEntryEntity: EntryEntity) {
        startedEntryEntity.end = Date()
        startedEntryEntity.intervalStarted = false
        save()
    }
    
    private func save() {
        do {
            try moc.save()
            self.error = nil
        } catch {
            self.error = LogError.CoreDataError.save
            return
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
