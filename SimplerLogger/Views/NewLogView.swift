//
//  NewLogView.swift
//  SimplerLogger
//
//  Created by David Rynn on 6/8/22.
//

import SwiftData
import SwiftUI

struct NewLogView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var name: String = ""
    @State private var useIntervals = false
    @State private var error: Error?
    let defaultPadding = 10.0

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
                TextField("Please enter name here.", text: $name) {
                    done()
                }
            }
        }
        .navigationBarItems(leading: Button("Cancel") { dismiss() }, trailing: Button("Done") { done() })
    }

    private func done() {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            dismiss()
            return
        }
        do {
            try LogStore(context: context).createLog(named: name, usesIntervals: useIntervals)
            dismiss()
        } catch {
            self.error = error
        }
    }
}
