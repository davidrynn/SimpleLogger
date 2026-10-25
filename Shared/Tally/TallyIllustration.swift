//
//  TallyIllustration.swift
//  SimplerLogger
//

import SwiftUI

/// The first-launch picture: a cap above a window reading "0000", like a counter nobody has used yet.
struct TallyIllustration: View {
    var body: some View {
        VStack(spacing: 12) {
            TallyCap(diameter: 52, isPressed: false) { EmptyView() }
            CountWindow(text: "0000", size: .large)
        }
        .accessibilityHidden(true)
    }
}
