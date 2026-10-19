//
//  EntryDetailsView.swift
//  SimplerLogger
//
//  Created by David Rynn on 5/29/22.
//

import SwiftData
import SwiftUI

/// Edits one entry. Every change saves as it's made, so there's no Done button.
struct EntryDetailsView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    let entry: LogEntry
    /// The text field edits this copy; each change is saved to the entry through `LogStore`.
    @State private var note: String
    @State private var confirmingDelete = false
    @State private var error: Error?

    private var store: LogStore { LogStore(context: context) }

    init(entry: LogEntry) {
        self.entry = entry
        _note = State(initialValue: entry.note)
    }

    var body: some View {
        Form {
            Section {
                DatePicker("Start", selection: startBinding, in: ...(entry.end ?? .now))
                if entry.isInterval {
                    if entry.end != nil {
                        DatePicker("End", selection: endBinding, in: entry.start...Date.now)
                        LabeledContent("Duration", value: entry.durationText ?? "")
                    } else {
                        LabeledContent("Duration") {
                            Text(entry.start, style: .timer).monospacedDigit()
                        }
                        Button("Stop Now", systemImage: "stop.fill") {
                            perform { if let log = entry.log { try store.stopInterval(in: log) } }
                        }
                        .tint(.red)
                    }
                }
            }
            Section("Note") {
                TextField("Add a note", text: $note, axis: .vertical)
                    .lineLimit(3...)
            }
            Section {
                Button("Delete Entry", role: .destructive) { confirmingDelete = true }
                    .frame(maxWidth: .infinity)
                    // Attached here so the dialog points at this button.
                    .confirmationDialog("Delete this entry?", isPresented: $confirmingDelete, titleVisibility: .visible) {
                        Button("Delete Entry", role: .destructive) {
                            perform {
                                try store.delete([entry])
                                dismiss()
                            }
                        }
                    }
            }
        }
        .navigationTitle(entry.start.dayTitle())
        .navigationBarTitleDisplayMode(.inline)
        // Reads the other fields from the entry at save time, so a timer stopped elsewhere stays stopped.
        .onChange(of: note) { _, note in
            save(start: entry.start, end: entry.end, note: note)
        }
        .errorAlert($error)
    }

    /// Writes through `LogStore` (which validates and saves), reading the other fields from the entry as it is now.
    private var startBinding: Binding<Date> {
        Binding(get: { entry.start }, set: { save(start: $0, end: entry.end, note: note) })
    }

    /// Like `startBinding`. Only shown once the interval has ended, so the `.now` fallback isn't seen.
    private var endBinding: Binding<Date> {
        Binding(get: { entry.end ?? .now }, set: { save(start: entry.start, end: $0, note: note) })
    }

    private func save(start: Date, end: Date?, note: String) {
        perform { try store.update(entry, start: start, end: end, note: note) }
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
