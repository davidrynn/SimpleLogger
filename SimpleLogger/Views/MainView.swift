//
//  MainView.swift
//  SimpleLogger
//
//  Created by David Rynn on 5/22/22.
//

import SwiftUI

struct MainView: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: []) var logs: FetchedResults<LogEntity>
    @State var didStart = false
    @State var didStop = false
    @State var startTime = Date()
    @State var stopTime = Date()
    @State var errorText = ""
    @State var animate = false
    
    var body: some View {
        NavigationView {
                List {
                    ForEach(logs, id: \.self) { logEntity in
                        let log = Log(id: logEntity.id ?? UUID(), entries: logEntity.entries, name: logEntity.name ?? "no name", usesInterval: logEntity.usesIntervals)
                        NavigationLink(destination: LogView(log: logEntity)) {
                            MainRow(log: log) {
                                startTime = Date()
                                if log.usesInterval && !didStart {
                                    didStart = true
                                    return true
                                }
                                if log.usesInterval && didStart {
                                    didStart = false
                                    self.stopTime = Date()
                                }
                                addEntry(log)
                                return false
                            }
                            .onChange(of: didStart) { _ in
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    didStart ? (animate = true) : (animate = false)
                                }
                            }
                        }
                    }
                    .onDelete(perform: delete)
            }
            .navigationBarTitle("Logs")
            .toolbar {
                ToolbarItem {
                    let destination = LogView(log: nil)
                    NavigationLink(destination: destination) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
    }
    
    private func delete(at offsets: IndexSet) {
        offsets.forEach { index in
            moc.delete(logs[index])
        }
        do {
            try moc.save()
        } catch {
            print(error)
        }
    }
    
    private func addEntry(_ log: Log) {
        let logEntity = logs.first { $0.id == log.id }
        let newEntry = EntryEntity(context: moc)
        newEntry.id = UUID()
        newEntry.start = startTime
        newEntry.end = stopTime
        logEntity?.addToEntryEntities(newEntry)
        do {
            try moc.save()
        } catch {
            errorText = "unable to save"
            return
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
