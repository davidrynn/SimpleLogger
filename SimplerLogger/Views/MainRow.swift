//
//  MainRow.swift
//  SimplerLogger
//
//  Created by David Rynn on 5/22/22.
//

import SwiftUI

/// A row in the main list: the counter's name, a summary or live timer, today's count, and its one-tap button.
struct MainRow: View {
    let log: Log
    /// Hides the button in edit mode, so a stray tap there can't log anything.
    let isEditing: Bool
    /// The log's primary action, run when the button is tapped.
    let action: () -> Void
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        HStack(spacing: 14) {
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

            // At accessibility sizes the name needs the room; the summary already says the count.
            if !dynamicTypeSize.isAccessibilitySize {
                CountWindow(text: CountWindow.countText(log.entries(onSameDayAs: .now).count))
            }

            if !isEditing {
                LogActionButton(log: log, action: action)
            }
        }
        .padding(.vertical, 4)
    }
}

/// The one button on every counter (`LogStore.primaryAction`): count, start or stop. Drawn as a tally cap.
struct LogActionButton: View {
    let log: Log
    let action: () -> Void

    var body: some View {
        // The cap clicks (haptic and sound) as it's pressed and released; see `TallyCapButtonStyle`.
        Button(action: action) {
            Image(systemName: log.actionSymbol)
                .font(.title3.weight(.bold))
                // The cap stops growing at 1.5x (`TallyCapButtonStyle`), so the icon stops too.
                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                .foregroundStyle(log.isRunning ? Color.tallyRunning : .tallyInk)
                .contentTransition(.symbolEffect(.replace))
        }
        .buttonStyle(TallyCapButtonStyle())
        .accessibilityLabel(log.actionLabel)
    }
}
