//
//  MainView.swift
//  SimplerLoggerWatch
//
//  Created by David Rynn on 5/27/22.
//

import SwiftData
import SwiftUI

/// The watch is for logging: every row is one tap. Logs are made and edited on iPhone.
struct MainView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Log.sortIndex) private var logs: [Log]
    @State private var error: Error?

    var body: some View {
        NavigationStack {
            Group {
                if logs.isEmpty {
                    ContentUnavailableView(
                        "No Logs Yet",
                        systemImage: "checkmark.circle",
                        description: Text("Make a log on your iPhone and it shows up here.")
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
            .navigationTitle("Logs")
        }
        .errorAlert($error)
    }
}
