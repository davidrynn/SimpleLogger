//
//  LogView.swift
//  SimplerLogger
//
//  Created by David Rynn on 5/22/22.
//

import CoreData
import SwiftUI

struct LogView: View {
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var dataController: DataController
    @ObservedObject var viewModel: LogViewModel
    @State var presentingSheet = false
    var animation: Animation {
        if started {
            return Animation.linear(duration: 1).repeatForever()
        } else {
            return Animation.default
        }
    }
    @State var started = false
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
}
