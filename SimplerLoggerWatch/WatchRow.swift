//
//  WatchRow.swift
//  SimplerLoggerWatch
//
//  Created by David Rynn on 5/28/22.
//

import SwiftUI

/// The whole row is the log's button (`LogStore.primaryAction`), the biggest target the watch allows.
struct WatchRow: View {
    let log: Log
    let action: () -> Void
    /// Counts taps to trigger haptics. Keying them to the log's state would also buzz on synced changes.
    @State private var taps = 0

    var body: some View {
        Button {
            taps += 1
            action()
        } label: {
            VStack(alignment: .leading, spacing: 2) {
                Text(log.name)
                    .font(.headline)
                if let running = log.runningEntry {
                    Text("Running \(running.start, style: .timer)")
                        .monospacedDigit()
                        .foregroundStyle(.red)
                } else {
                    Text(log.summary(compact: true))
                        .foregroundStyle(.secondary)
                }
            }
            .font(.footnote)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 4)
        }
        // The cap presses down when any part of the row is tapped.
        .buttonStyle(TallyCapRowButtonStyle(
            symbol: log.actionSymbol,
            symbolColor: log.isRunning ? .tallyRunning : .tallyInk,
            diameter: 34,
            capEdge: .trailing
        ))
        // Evaluated after the action, so it reflects the new state.
        .sensoryFeedback(trigger: taps) { _, _ in
            if log.isRunning { return .start }
            return log.usesIntervals ? .stop : .success
        }
        .accessibilityLabel(log.actionLabel)
        .accessibilityValue(log.isRunning ? Text("Running") : Text(log.summary()))
    }
}
