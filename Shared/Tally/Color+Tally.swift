//
//  Color+Tally.swift
//  SimplerLogger
//

import SwiftUI

extension Color {
    /// A color from a 0xRRGGBB literal.
    init(rgb: UInt32) {
        self.init(
            red: Double((rgb >> 16) & 0xFF) / 255,
            green: Double((rgb >> 8) & 0xFF) / 255,
            blue: Double(rgb & 0xFF) / 255
        )
    }

    /// Icons on a cap: near-black, since the cap is light metal in both light and dark mode.
    static let tallyInk = Color(rgb: 0x2B2D30)
    /// A running timer's stop icon and text. Darker than system red so it reads on the metal cap.
    static let tallyRunning = Color(rgb: 0xC4001A)
}
