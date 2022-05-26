//
//  MainRow.swift
//  SimpleLogger
//
//  Created by David Rynn on 5/22/22.
//

import SwiftUI

struct MainRow: View {
    let name: String
    let count: Int
    var startAnimating: () -> (Bool)
    @State var didStart = false
    var body: some View {
        HStack {
            Text(name)
                .truncationMode(.tail)
            Spacer()
            Text("Entries: \(count)")
            Spacer()
            Button(didStart ? "logging..." : "Log") {
                didStart = startAnimating()
            }
            .animation(didStart ? .easeIn(duration: 1).repeatForever() : .default, value: didStart)
            .buttonStyle(.bordered)
        }
        .padding()
    }
}

struct MainRow_Previews: PreviewProvider {
    static var previews: some View {
        MainRow(name: "Test", count: 2, startAnimating: {true})
    }
}
