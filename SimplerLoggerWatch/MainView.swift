//
//  MainView.swift
//  SimplerLoggerWatch
//
//  Created by David Rynn on 5/27/22.
//

import SwiftData
import SwiftUI

struct MainView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Log.sortIndex) private var logs: [Log]
    @State private var error: Error?

    var body: some View {
        List {
            if let error {
                Text(error.localizedDescription)
            }
            ForEach(logs) { log in
                WatchRow(log: log) {
                    do {
                        try LogStore(context: context).primaryAction(for: log)
                        error = nil
                    } catch {
                        self.error = error
                    }
                }
            }
        }
    }
}
