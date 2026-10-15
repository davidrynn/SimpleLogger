//
//  MainRow.swift
//  SimplerLogger
//
//  Created by David Rynn on 5/22/22.
//

import SwiftUI

struct MainRow: View {
    @State var name: String
    var animation: Animation {
        if didStart {
            return Animation.linear(duration: 2.0).repeatForever(autoreverses: false)
        }
        return Animation.default
    }
    var backgroundAnimation: Animation {
        if didStart {
            return Animation.linear(duration: 1.0).repeatForever(autoreverses: true)
        }
        return Animation.default
    }
    let count: Int
    @State var didStart: Bool
    var startAnimating: () -> (Bool)
    @State var editMode = EditMode.inactive
    var body: some View {
        HStack {
            if editMode == .active {
                TextField(name, text: $name)
            } else {
                Text(name)
                    .truncationMode(.tail)
            }
            Spacer()
            Text("Entries: \(count)")
            Spacer()
            Button(action: {
               let impactMed = UIImpactFeedbackGenerator(style: .medium)
               impactMed.impactOccurred()
               didStart = startAnimating()
           }, label: {
                   Image(systemName: "plus.circle")
                   .rotationEffect(Angle.degrees(didStart ? 300 : 0))
                   .animation(animation, value: didStart)
           })
            .opacity(didStart ? 0.5 : 1.0)
            .scaleEffect(didStart ? 0.9 : 1.0)
            .animation(backgroundAnimation, value: didStart)
            .buttonStyle(.bordered)
        }
        .padding()
    }
}

struct MainRow_Previews: PreviewProvider {
    static var previews: some View {
        MainRow(name: "Test", count: 2, didStart: true, startAnimating: {true})
    }
}
