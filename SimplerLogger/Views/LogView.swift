//
//  LogView.swift
//  SimplerLogger
//
//  Created by David Rynn on 5/22/22.
//

import SwiftData
import SwiftUI

/// A log's history by day, with its primary action pinned to the bottom.
struct LogView: View {
    @Environment(\.modelContext) private var context
    let log: Log
    @State private var showEditLog = false
    /// Set to ask for confirmation before deleting this entry.
    @State private var entryToDelete: LogEntry?
    /// Counts taps on the primary button to trigger haptics (see `LogActionButton`).
    @State private var taps = 0
    @State private var error: Error?

    private var store: LogStore { LogStore(context: context) }

    var body: some View {
        Group {
            if log.entryCount == 0 {
                ContentUnavailableView(
                    "No Entries Yet",
                    systemImage: log.usesIntervals ? "timer" : "checkmark.circle",
                    description: Text(log.usesIntervals ? "Tap Start to time it." : "Tap Add to log it now.")
                )
            } else {
                history
            }
        }
        .navigationTitle(log.name)
        .navigationDestination(for: LogEntry.self) { EntryDetailsView(entry: $0) }
        .toolbar {
            Button("Edit") { showEditLog = true }
        }
        .safeAreaInset(edge: .bottom) { primaryButton }
        .sheet(isPresented: $showEditLog) {
            NavigationStack { LogFormView(log: log) }
        }
        .errorAlert($error)
    }

    private var history: some View {
        List {
            ForEach(log.entriesByDay(), id: \.day) { day, entries in
                Section {
                    ForEach(entries) { entry in
                        NavigationLink(value: entry) { EntryRow(entry: entry) }
                            .swipeActions {
                                Button("Delete", systemImage: "trash") { entryToDelete = entry }
                                    .tint(.red)
                            }
                            // On the row, so the dialog points at the entry being deleted.
                            .confirmationDialog(
                                "Delete this entry?",
                                isPresented: Binding(
                                    get: { entryToDelete == entry },
                                    set: { if !$0 { entryToDelete = nil } }
                                ),
                                titleVisibility: .visible
                            ) {
                                Button("Delete Entry", role: .destructive) {
                                    perform { try store.delete([entry]) }
                                }
                            }
                    }
                } header: {
                    HStack {
                        Text(day.dayTitle())
                        Spacer()
                        dayTotal(entries)
                    }
                }
            }
        }
    }

    /// A section header's trailing text: total time for timer logs, otherwise the entry count.
    private func dayTotal(_ entries: [LogEntry]) -> Text {
        let total = entries.totalDuration
        if log.usesIntervals, total > 0 { return Text(DateComponentsFormatter.durationText(total)) }
        return Text("^[\(entries.count) entry](inflect: true)")
    }

    /// The log's primary action as a full-width button over the bottom of the list; red with elapsed time while running.
    private var primaryButton: some View {
        Button {
            taps += 1
            perform { try store.primaryAction(for: log) }
        } label: {
            Group {
                if let running = log.runningEntry {
                    Label {
                        Text("Stop  \(running.start, style: .timer)").monospacedDigit()
                    } icon: {
                        Image(systemName: "stop.fill")
                    }
                } else if log.usesIntervals {
                    Label("Start", systemImage: "play.fill")
                } else {
                    Label("Add", systemImage: "plus")
                }
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .tint(log.isRunning ? .red : .accentColor)
        .sensoryFeedback(.impact(weight: .medium), trigger: taps)
        .accessibilityLabel(log.actionLabel)
        .padding()
        .background(.bar)
    }

    /// Runs a store call and shows any error in an alert.
    private func perform(_ action: () throws -> Void) {
        do {
            try action()
        } catch {
            self.error = error
        }
    }
}

/// One entry in a log's history: its time, its duration or a live timer, and its note.
private struct EntryRow: View {
    let entry: LogEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(alignment: .firstTextBaseline) {
                Text(entry.timeText)
                Spacer()
                if entry.isRunning {
                    Text("Running \(entry.start, style: .timer)")
                        .monospacedDigit()
                        .foregroundStyle(.red)
                } else if let durationText = entry.durationText {
                    Text(durationText)
                        .foregroundStyle(.secondary)
                }
            }
            if !entry.note.isEmpty {
                Text(entry.note)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .accessibilityElement(children: .combine)
    }
}
