//
//  MainRow.swift
//  SimpleLogger
//
//  Created by David Rynn on 5/22/22.
//

import SwiftUI

struct MainRow: View {
    let log: Log
    var didLog: () -> (Bool)
    @State var didStart = false
    var body: some View {
        HStack {
            Text(log.name)
                .truncationMode(.tail)
            Spacer()
            Text("Entries: \(log.entries.count)")
            Spacer()
            Button(didStart ? "logging..." : "Log") {
                didStart = didLog()
            }
            .animation(didStart ? .easeIn(duration: 1).repeatForever() : .default, value: didStart)
            .buttonStyle(.bordered)
            .background(didStart ? .red : .gray)
        }
        .padding()
    }
}

struct MainRow_Previews: PreviewProvider {
    static var previews: some View {
        let log = Log(id: UUID(), entries: [], name: "Test", usesInterval: false)
        MainRow(log: log, didLog: {
            return false
        })
    }
}
