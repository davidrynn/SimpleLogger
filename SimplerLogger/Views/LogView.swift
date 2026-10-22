//
//  LogView.swift
//  SimplerLogger
//
//  Created by David Rynn on 5/22/22.
//

import SwiftData
import SwiftUI

/// A counter's history by day, under today's count in a tally window, with its primary action pinned to the bottom.
struct LogView: View {
    @Environment(\.modelContext) private var context
    let log: Log
    @State private var showEditLog = false
    /// Set to ask for confirmation before deleting this entry.
    @State private var entryToDelete: LogEntry?
    @State private var error: Error?

    private var store: LogStore { LogStore(context: context) }

    var body: some View {
        Group {
            if log.entryCount == 0 {
                ContentUnavailableView(
                    "Nothing Counted Yet",
                    systemImage: log.usesIntervals ? "timer" : "checkmark.circle",
                    description: Text(log.usesIntervals ? "Tap Start to time it." : "Tap Count to count it now.")
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
            countHeader
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

    /// Today's count in a tally window, or the running timer, with the summary under it.
    private var countHeader: some View {
        VStack(spacing: 10) {
            if let running = log.runningEntry {
                TimelineView(.periodic(from: running.start, by: 1)) { context in
                    CountWindow(text: CountWindow.timerText(context.date.timeIntervalSince(running.start)), size: .large)
                }
                // The time is already in the window, the entry row and the Stop button.
                Text("Running")
                    .foregroundStyle(.red)
            } else {
                CountWindow(text: CountWindow.countText(log.entries(onSameDayAs: .now).count), size: .large)
                Text(log.summary())
                    .foregroundStyle(.secondary)
            }
        }
        .font(.subheadline)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
        .listRowBackground(Color.clear)
    }

    /// A section header's trailing text: total time for timers, otherwise how many counts.
    private func dayTotal(_ entries: [LogEntry]) -> Text {
        let total = entries.totalDuration
        if log.usesIntervals, total > 0 { return Text(DateComponentsFormatter.durationText(total)) }
        return Text("^[\(entries.count) count](inflect: true)")
    }

    /// The counter's primary action as a big tally cap over the bottom of the list, named beside it;
    /// red with elapsed time while running. The cap clicks as it's pressed and released.
    private var primaryButton: some View {
        Button {
            perform { try store.primaryAction(for: log) }
        } label: {
            Group {
                if let running = log.runningEntry {
                    Text("Stop  \(running.start, style: .timer)")
                        .monospacedDigit()
                        .foregroundStyle(.red)
                } else if log.usesIntervals {
                    Text("Start")
                } else {
                    Text("Count")
                }
            }
            .font(.headline)
            .foregroundStyle(.primary)
        }
        .buttonStyle(TallyCapRowButtonStyle(
            symbol: log.actionSymbol,
            symbolColor: log.isRunning ? .tallyRunning : .tallyInk,
            diameter: 64,
            capEdge: .leading,
            spacing: 16
        ))
        .frame(maxWidth: .infinity)
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
