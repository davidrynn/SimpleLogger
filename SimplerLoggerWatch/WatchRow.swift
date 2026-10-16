//
//  WatchRow.swift
//  SimplerLoggerWatch WatchKit Extension
//
//  Created by David Rynn on 5/28/22.
//

import SwiftUI

struct WatchRow: View {
    let name: String
    var startAnimating: () -> (Bool)
    @State var didStart = false
    var body: some View {
        HStack {
            Text(name)
                .truncationMode(.tail)
            Spacer()
            Button(action: {
                didStart = startAnimating()
            }, label: {
                didStart ? Image(systemName: "timer") : Image(systemName: "plus")
            })
            .animation(didStart ? .easeIn(duration: 1).repeatForever() : .default, value: didStart)
            .buttonStyle(.bordered)
        }
        .padding()
    }
}

struct WatchRow_Previews: PreviewProvider {
    static var previews: some View {
        WatchRow(name: "Test", startAnimating: {true})
    }
}

