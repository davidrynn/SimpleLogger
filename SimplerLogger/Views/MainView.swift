//
//  MainView.swift
//  SimplerLogger
//
//  Created by David Rynn on 5/22/22.
//

import SwiftData
import SwiftUI

struct MainView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Log.sortIndex) private var logs: [Log]
    @State private var showAddView = false
    @State private var error: Error?

    private var store: LogStore { LogStore(context: context) }

    var body: some View {
        NavigationView {
            VStack {
                if let error {
                    Text("Error: \(error.localizedDescription)")
                }
                if logs.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(logs) { log in
                            NavigationLink(destination: LogView(log: log)) {
                                MainRow(log: log) { perform { try store.primaryAction(for: log) } }
                            }
                        }
                        .onDelete { offsets in
                            perform { try offsets.map { logs[$0] }.forEach(store.delete) }
                        }
                        .onMove { source, destination in
                            perform { try store.moveLogs(logs, fromOffsets: source, toOffset: destination) }
                        }
                    }
                }
            }
            .navigationBarTitle("Logs")
            .navigationBarItems(leading: EditButton(), trailing: Button(action: {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                showAddView.toggle()
            }, label: {
                Image(systemName: "plus")
            })
            .sheet(isPresented: $showAddView) {
                NavigationView {
                    NewLogView()
                }
            })
        }
        .navigationViewStyle(.stack)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()
            Text("Log anything with one tap")
                .font(.headline)
            Text("Make a log for something you want to track, like watering the plants. Tap its button to record that it happened, or to start and stop a timer.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding()
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
