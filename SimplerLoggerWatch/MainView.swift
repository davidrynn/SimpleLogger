//
//  MainView.swift
//  SimplerLoggerWatch
//
//  Created by David Rynn on 5/27/22.
//

import SwiftData
import SwiftUI

/// The watch is for counting: every row is one tap. Counters are made and edited on iPhone.
struct MainView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Log.sortIndex) private var logs: [Log]
    @State private var error: Error?

    var body: some View {
        NavigationStack {
            Group {
                if logs.isEmpty {
                    ContentUnavailableView(
                        "No Counters Yet",
                        systemImage: "checkmark.circle",
                        description: Text("Make a counter on your iPhone and it shows up here.")
                    )
                } else {
                    List(logs) { log in
                        WatchRow(log: log) {
                            do {
                                try LogStore(context: context).primaryAction(for: log)
                            } catch {
                                self.error = error
                            }
                        }
                    }
                }
            }
            .navigationTitle("Counters")
        }
        .errorAlert($error)
    }
}
