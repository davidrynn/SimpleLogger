//
//  MainRow.swift
//  SimplerLogger
//
//  Created by David Rynn on 5/22/22.
//

import SwiftUI

/// A row in the main list: the log's name, a summary or live timer, and its one-tap button.
struct MainRow: View {
    let log: Log
    /// Hides the button in edit mode, so a stray tap there can't log anything.
    let isEditing: Bool
    /// The log's primary action, run when the button is tapped.
    let action: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(log.name)
                    .font(.body)
                if let running = log.runningEntry {
                    // Text(_:style: .timer) counts up from the start and updates itself.
                    Text("Running \(running.start, style: .timer)")
                        .monospacedDigit()
                        .foregroundStyle(.red)
                } else {
                    Text(log.summary())
                        .foregroundStyle(.secondary)
                }
            }
            .font(.subheadline)
            .frame(maxWidth: .infinity, alignment: .leading)

            if !isEditing {
                LogActionButton(log: log, action: action)
            }
        }
        .padding(.vertical, 4)
    }
}

/// The one button on every log (`LogStore.primaryAction`): add, start or stop.
struct LogActionButton: View {
    let log: Log
    let action: () -> Void
    /// Counts taps to trigger haptics. Keying them to the log's state would also buzz on synced changes.
    @State private var taps = 0

    var body: some View {
        Button {
            taps += 1
            action()
        } label: {
            Image(systemName: log.actionSymbol)
                .font(.title3.weight(.semibold))
                .frame(minWidth: 28, minHeight: 28)
                .contentTransition(.symbolEffect(.replace))
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.circle)
        .tint(log.isRunning ? .red : .accentColor)
        .sensoryFeedback(.impact(weight: .medium), trigger: taps)
        .accessibilityLabel(log.actionLabel)
    }
}
