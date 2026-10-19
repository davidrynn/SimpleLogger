//
//  WatchRow.swift
//  SimplerLoggerWatch
//
//  Created by David Rynn on 5/28/22.
//

import SwiftUI

struct WatchRow: View {
    let log: Log
    let action: () -> Void

    var body: some View {
        HStack {
            Text(log.name)
                .truncationMode(.tail)
            Spacer()
            Button(action: action) {
                Image(systemName: log.isRunning ? "timer" : "plus")
            }
            .animation(log.isRunning ? .easeIn(duration: 1).repeatForever() : .default, value: log.isRunning)
            .buttonStyle(.bordered)
        }
        .padding()
    }
}
