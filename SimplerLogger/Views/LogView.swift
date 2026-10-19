//
//  LogView.swift
//  SimplerLogger
//
//  Created by David Rynn on 5/22/22.
//

import SwiftData
import SwiftUI

struct LogView: View {
    @Environment(\.modelContext) private var context
    let log: Log
    @State private var presentingSheet = false
    @State private var error: Error?

    private var store: LogStore { LogStore(context: context) }
    private var started: Bool { log.isRunning }
    private var buttonText: String {
        if started { return "Stop" }
        return log.usesIntervals ? "Start" : "Add"
    }

    var body: some View {
        VStack {
            if let error {
                Text("Error: \(error.localizedDescription)")
            }

            List {
                ForEach(log.entriesByDay(), id: \.day) { day, entries in
                    Section(header: Text("\(day.formatted(date: .abbreviated, time: .omitted))     count: \(entries.count)")) {
                        ForEach(entries) { entry in
                            NavigationLink(destination: EntryDetailsView(entry: entry)) {
                                VStack {
                                    Text(entry.start.formatted(date: .long, time: .standard))
                                    if let end = entry.end {
                                        if let durationText = entry.durationText {
                                            Text(durationText)
                                        }
                                        Text(end.formatted(date: .long, time: .standard))
                                    } else if entry.isRunning {
                                        Text("Running")
                                    }
                                }
                            }
                        }
                        .onDelete { offsets in
                            perform { try store.delete(offsets.map { entries[$0] }) }
                        }
                    }
                }
            }

            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                perform { try store.primaryAction(for: log) }
            } label: {
                Text(buttonText)
            }
            .scaleEffect(started ? 0.9 : 1.0)
            .opacity(started ? 0.5 : 1.0)
            .animation(started ? .linear(duration: 1).repeatForever() : .default, value: started)
            .buttonStyle(.bordered)
            .navigationBarTitle(log.name, displayMode: .automatic)
            .toolbar {
                ToolbarItemGroup {
                    Button("Edit") {
                        presentingSheet = true
                    }
                    .sheet(isPresented: $presentingSheet) {
                        NavigationView {
                            UpdateLogView(log: log)
                        }
                    }
                }
            }
        }
    }

    private func perform(_ action: () throws -> Void) {
        do {
            try action()
            error = nil
        } catch {
            self.error = error
        }
    }
}
