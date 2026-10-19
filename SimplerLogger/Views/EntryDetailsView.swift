//
//  EntryDetailsView.swift
//  SimplerLogger
//
//  Created by David Rynn on 5/29/22.
//

import SwiftData
import SwiftUI

struct EntryDetailsView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    let entry: LogEntry
    @State private var startDate: Date
    @State private var stopDate: Date?
    @State private var note: String
    @State private var error: Error?

    private var store: LogStore { LogStore(context: context) }

    init(entry: LogEntry) {
        self.entry = entry
        _startDate = State(initialValue: entry.start)
        _stopDate = State(initialValue: entry.end)
        _note = State(initialValue: entry.note)
    }

    var body: some View {
        List {
            VStack {
                if let error {
                    Text("Error: \(error.localizedDescription)")
                        .foregroundColor(.red)
                }
                DatePicker(selection: $startDate, in: ...Date(), displayedComponents: [.date, .hourAndMinute]) {
                    Text("Edit")
                }
                Text("Start time: \(startDate.formatted(date: .long, time: .standard))")
                if let stop = stopDate {
                    if let durationText = DateComponentsFormatter.duration.string(from: startDate, to: stop) {
                        Text(durationText)
                    }
                    DatePicker(selection: $stopDate.bound, in: ...Date(), displayedComponents: [.date, .hourAndMinute]) {
                        Text("Edit")
                    }
                    Text("Stop time: \(stop.formatted(date: .long, time: .standard))")
                }
                TextField("Note", text: $note) {
                    save()
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                HStack {
                    Button {
                        do {
                            try store.delete([entry])
                            dismiss()
                        } catch {
                            self.error = error
                        }
                    } label: {
                        Image(systemName: "trash")
                    }
                    Button {
                        if save() { dismiss() }
                    } label: {
                        Text("done")
                    }
                }
            }
        }
    }

    @discardableResult
    private func save() -> Bool {
        do {
            try store.update(entry, start: startDate, end: stopDate, note: note)
            error = nil
            return true
        } catch {
            self.error = error
            return false
        }
    }
}

extension Optional where Wrapped == Date {
    var bound: Date {
        get { self ?? Date() }
        set { self = newValue }
    }
}
