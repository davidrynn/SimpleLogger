//
//  MainView.swift
//  SimplerLogger
//
//  Created by David Rynn on 5/22/22.
//

import SwiftData
import SwiftUI

/// The iPhone's home screen: the list of counters, each with its one-tap button. Counting from here is the main path.
struct MainView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Log.sortIndex) private var logs: [Log]
    /// Owned here, not left to `EditButton`, so the rows can see it and hide their buttons.
    @State private var editMode: EditMode = .inactive
    @State private var showNewLog = false
    /// Set to show the Edit Log sheet for this log.
    @State private var logToEdit: Log?
    /// Set to ask for confirmation before deleting this log.
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
            .navigationTitle("Counters")
            .navigationDestination(for: Log.self) { LogView(log: $0) }
            .toolbar {
                if !logs.isEmpty {
                    ToolbarItem(placement: .topBarLeading) { EditButton() }
                }
                ToolbarItem(placement: .primaryAction) {
                    // Text, not a +, so the only + on the screen is the one that counts.
                    Button("New") { showNewLog = true }
                        .fontWeight(.semibold)
                        .accessibilityLabel("New Counter")
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
                    // On the row, so the dialog points at the log being deleted.
                    .confirmationDialog(
                        "Delete “\(log.name)”?",
                        isPresented: Binding(get: { logToDelete == log }, set: { if !$0 { logToDelete = nil } }),
                        titleVisibility: .visible
                    ) {
                        Button("Delete Counter", role: .destructive) {
                            perform { try store.delete(log) }
                        }
                    } message: {
                        Text(log.entryCount == 0 ? "Nothing has been counted yet." : "This also deletes its ^[\(log.entryCount) count](inflect: true).")
                    }
            }
            .onDelete { offsets in
                logToDelete = offsets.first.map { logs[$0] }
            }
            // Only while editing: otherwise holding a row starts a drag, which cancels a held cap.
            .onMove(perform: moveAction)
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
                .accessibilityHint("Edits the counter's name and settings")
        } else {
            NavigationLink(value: log) { mainRow }
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            VStack(spacing: 28) {
                TallyIllustration()
                Text("Count Anything with One Tap")
            }
        } description: {
            Text("Make a counter for something you want to keep track of, like watering the plants. Tap its button to count it, or to start and stop a timer.")
        } actions: {
            Button("Make Your First Counter") { showNewLog = true }
                .buttonStyle(.borderedProminent)
        }
    }

    /// Reordering, only in edit mode (see `list`).
    private var moveAction: ((IndexSet, Int) -> Void)? {
        guard isEditing else { return nil }
        return { source, destination in
            perform { try store.moveLogs(logs, fromOffsets: source, toOffset: destination) }
        }
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
