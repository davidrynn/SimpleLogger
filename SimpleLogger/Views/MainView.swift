//
//  MainView.swift
//  SimpleLogger
//
//  Created by David Rynn on 5/22/22.
//

import SwiftUI

struct MainView: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \LogEntity.index, ascending: true)],
        animation: .default)
    private var logs: FetchedResults<LogEntity>
    @EnvironmentObject var dataController: DataController
    @State private var showAddView = false
    @State var didStart = false
    @State var didStop = false
    @State var startTime = Date()
    @State var stopTime = Date()
    @State var animate = false
    @State var error: Error?
    @State var intialName = "No Title"
    @State var initialBool = false
    
    var body: some View {
        NavigationView {
            VStack{
                if error != nil {
                    Text("Error: \(error.debugDescription)")
                }
                List {
                    ForEach(logs, id: \.self) { log in
                        NavigationLink(destination: LogView(log: log)) {
                            let startedEntry = startedEntry(log)
                            MainRow(name: log.name ?? "No Name", count: log.entryEntities?.count ?? 0, didStart: startedEntry != nil) {
                                startTime = Date()
                                //if started animating, stop interval and stop animation
                                if let startedEntry = startedEntry {
                                    stopInterval(startedEntry)
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
                    .onDelete(perform: delete)
                    .onMove(perform: moveItem)
                }
            }
            .navigationBarTitle("Logs")
            .navigationBarItems(leading: EditButton(), trailing: Button(action: {
                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                impactMed.impactOccurred()
                showAddView.toggle()
            }, label: {
                    Image(systemName: "plus")
            })
                .sheet(isPresented: $showAddView, content: {
                    NavigationView {
                        NewLogView()
                    }
                })
            )
        }
        .navigationViewStyle(.stack)
    }
    
    private func startedEntry(_ log: LogEntity) -> EntryEntity? {
        return log.entryEntities?.first(where: { item in
            if let entryEntity = item as? EntryEntity {
                return entryEntity.intervalStarted
            }
            return false
        }) as? EntryEntity
    }
    
    private func moveItem(at sets:IndexSet, destination:Int){
            let itemToMove = sets.first!
            
            if itemToMove < destination{
                var startIndex = itemToMove + 1
                let endIndex = destination - 1
                var startOrder = logs[itemToMove].index
                while startIndex <= endIndex{
                    logs[startIndex].index = startOrder
                    startOrder = startOrder + 1
                    startIndex = startIndex + 1
                }
                logs[itemToMove].index = startOrder
            }
            else if destination < itemToMove{
                var startIndex = destination
                let endIndex = itemToMove - 1
                var startOrder = logs[destination].index + 1
                let newOrder = logs[destination].index
                while startIndex <= endIndex{
                    logs[startIndex].index = startOrder
                    startOrder = startOrder + 1
                    startIndex = startIndex + 1
                }
                logs[itemToMove].index = newOrder
            }
        save()
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

//struct MainView_Previews: PreviewProvider {
//    static var previews: some View {
//        MainView()
//    }
//}
