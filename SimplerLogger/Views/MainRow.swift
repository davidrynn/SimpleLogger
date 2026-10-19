//
//  MainRow.swift
//  SimplerLogger
//
//  Created by David Rynn on 5/22/22.
//

import SwiftUI

struct MainRow: View {
    let log: Log
    let action: () -> Void

    private var isRunning: Bool { log.isRunning }

    var body: some View {
        HStack {
            Text(log.name)
                .truncationMode(.tail)
            Spacer()
            Text("Entries: \(log.entryCount)")
            Spacer()
            Button(action: {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                action()
            }, label: {
                Image(systemName: "plus.circle")
                    .rotationEffect(Angle.degrees(isRunning ? 300 : 0))
                    .animation(isRunning ? .linear(duration: 2.0).repeatForever(autoreverses: false) : .default, value: isRunning)
            })
            .opacity(isRunning ? 0.5 : 1.0)
            .scaleEffect(isRunning ? 0.9 : 1.0)
            .animation(isRunning ? .linear(duration: 1.0).repeatForever(autoreverses: true) : .default, value: isRunning)
            .buttonStyle(.bordered)
        }
        .padding()
    }
}
