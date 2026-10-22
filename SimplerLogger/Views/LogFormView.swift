//
//  LogFormView.swift
//  SimplerLogger
//
//  Created by David Rynn on 6/8/22.
//

import SwiftData
import SwiftUI

/// The New Counter and Edit Counter sheets. Nothing is saved until Done.
struct LogFormView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    /// Nil to make a new log.
    let log: Log?
    @State private var name: String
    @State private var usesTimer: Bool
    @State private var error: Error?
    @FocusState private var nameFocused: Bool
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    init(log: Log?) {
        self.log = log
        _name = State(initialValue: log?.name ?? "")
        _usesTimer = State(initialValue: log?.usesIntervals ?? false)
    }

    private var isNameValid: Bool { !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

    var body: some View {
        Form {
            Section {
                TextField("Name", text: $name)
                    .focused($nameFocused)
                    .submitLabel(.done)
                    .onSubmit(done)
            } footer: {
                if log == nil {
                    Text("For example, “Water plants” or “Reading”.")
                }
            }
            Section {
                if dynamicTypeSize.isAccessibilitySize {
                    // A segment can't wrap its title, so at these sizes the choices become rows.
                    eachTapPicker.pickerStyle(.inline)
                } else {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Each tap")
                        eachTapPicker
                            .labelsHidden()
                            .pickerStyle(.segmented)
                    }
                    .padding(.vertical, 4)
                }
            } footer: {
                Text(timerFooter)
            }
        }
        .navigationTitle(log == nil ? "New Counter" : "Edit Counter")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Done", action: done)
                    .disabled(!isNameValid)
            }
        }
        .presentationDetents([.medium, .large])
        .onAppear { nameFocused = log == nil }
        .errorAlert($error)
    }

    /// Whether a tap counts or starts and stops a timer (`usesIntervals`).
    private var eachTapPicker: some View {
        Picker("Each tap", selection: $usesTimer) {
            Text("Counts it").tag(false)
            Text("Starts or stops a timer").tag(true)
        }
    }

    /// Explains the Each tap choice, and warns when turning it off will stop a running timer.
    private var timerFooter: String {
        if let log, log.isRunning, !usesTimer {
            return String(localized: "The timer that's running now will stop when you tap Done.")
        }
        return usesTimer
            ? String(localized: "One tap starts a timer and the next tap stops it.")
            : String(localized: "Each tap counts it once, with the time.")
    }

    /// Saves through `LogStore` and closes the sheet; on failure the sheet stays open and shows the error.
    private func done() {
        guard isNameValid else { return }
        do {
            let store = LogStore(context: context)
            if let log {
                try store.update(log, name: name, usesIntervals: usesTimer)
            } else {
                try store.createLog(named: name, usesIntervals: usesTimer)
            }
            dismiss()
        } catch {
            self.error = error
        }
    }
}
