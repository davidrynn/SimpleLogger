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
    @State private var editMode: EditMode = .inactive
    @State private var showNewLog = false
    @State private var logToEdit: Log?
    @State private var logToDelete: Log?
    @State private var error: Error?

    private var store: LogStore { LogStore(context: context) }
    private var isEditing: Bool { editMode.isEditing }

    var body: some View {
        NavigationStack {
            Group {
                if logs.isEmpty {
                    emptyState
                } else {
                    list
                }
            }
            .navigationTitle("Logs")
            .navigationDestination(for: Log.self) { LogView(log: $0) }
            .toolbar {
                if !logs.isEmpty {
                    ToolbarItem(placement: .topBarLeading) { EditButton() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("New Log", systemImage: "plus") { showNewLog = true }
                }
            }
            .environment(\.editMode, $editMode)
        }
        .sheet(isPresented: $showNewLog) {
            NavigationStack { LogFormView(log: nil) }
        }
        .sheet(item: $logToEdit) { log in
            NavigationStack { LogFormView(log: log) }
        }
        .errorAlert($error)
        .onChange(of: logs.isEmpty) { _, isEmpty in
            if isEmpty { editMode = .inactive }
        }
    }

    private var list: some View {
        List {
            ForEach(logs) { log in
                row(for: log)
                    .swipeActions(edge: .trailing) {
                        // Not role: .destructive, which removes the row before the confirmation is answered.
                        Button("Delete", systemImage: "trash") { logToDelete = log }
                            .tint(.red)
                    }
                    .swipeActions(edge: .leading) {
                        Button("Edit", systemImage: "pencil") { logToEdit = log }
                    }
                    .contextMenu {
                        Button("Edit", systemImage: "pencil") { logToEdit = log }
                        Button("Delete", systemImage: "trash", role: .destructive) { logToDelete = log }
                    }
                    // On the row, so the dialog points at the log being deleted.
                    .confirmationDialog(
                        "Delete “\(log.name)”?",
                        isPresented: Binding(get: { logToDelete == log }, set: { if !$0 { logToDelete = nil } }),
                        titleVisibility: .visible
                    ) {
                        Button("Delete Log", role: .destructive) {
                            perform { try store.delete(log) }
                        }
                    } message: {
                        Text(log.entryCount == 0 ? "It has no entries." : "This also deletes its ^[\(log.entryCount) entry](inflect: true).")
                    }
            }
            .onDelete { offsets in
                logToDelete = offsets.first.map { logs[$0] }
            }
            .onMove { source, destination in
                perform { try store.moveLogs(logs, fromOffsets: source, toOffset: destination) }
            }
        }
    }

    /// In edit mode a tap opens the log's settings (to rename it) instead of its history.
    @ViewBuilder
    private func row(for log: Log) -> some View {
        let mainRow = MainRow(log: log, isEditing: isEditing) {
            perform { try store.primaryAction(for: log) }
        }
        if isEditing {
            Button { logToEdit = log } label: { mainRow }
                .foregroundStyle(.primary)
                .accessibilityHint("Edits the log's name and settings")
        } else {
            NavigationLink(value: log) { mainRow }
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("Log Anything with One Tap", systemImage: "checkmark.circle")
        } description: {
            Text("Make a log for something you want to track, like watering the plants. Tap its button to record that it happened, or to start and stop a timer.")
        } actions: {
            Button("Make Your First Log") { showNewLog = true }
                .buttonStyle(.borderedProminent)
        }
    }

    private func perform(_ action: () throws -> Void) {
        do {
            try action()
        } catch {
            self.error = error
        }
    }
}
