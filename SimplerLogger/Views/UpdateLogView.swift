//
//  UpdateLogView.swift
//  SimplerLogger
//
//  Created by David Rynn on 6/9/22.
//

import SwiftData
import SwiftUI

struct UpdateLogView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    let log: Log
    @State private var name: String
    @State private var useIntervals: Bool
    @State private var error: Error?
    let defaultPadding = 10.0

    init(log: Log) {
        self.log = log
        _name = State(initialValue: log.name)
        _useIntervals = State(initialValue: log.usesIntervals)
    }

    var body: some View {
        Form {
            if let error {
                Text("Error: \(error.localizedDescription)")
            }
            Section(header: Text("Start and stop over an interval of time for an entry?")) {
                Toggle("Use Intervals", isOn: $useIntervals)
                    .padding(defaultPadding)
            }
            Section(header: Text("Log Name")) {
                TextField("Log Name", text: $name) {
                    done()
                }
            }
        }
        .navigationBarItems(trailing: Button("Done") { done() })
    }

    /// Saves explicitly on Done rather than on every keystroke.
    private func done() {
        do {
            try LogStore(context: context).update(log, name: name, usesIntervals: useIntervals)
            dismiss()
        } catch {
            self.error = error
        }
    }
}
