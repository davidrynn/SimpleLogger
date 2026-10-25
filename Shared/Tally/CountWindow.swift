//
//  CountWindow.swift
//  SimplerLogger
//

import SwiftUI

/// The counter's window: white digits on dark drums, in a metal bezel. Purely visual, so it's hidden from
/// VoiceOver; the same number is always in the text next to it.
struct CountWindow: View {
    enum Size {
        case small, large
    }

    /// Digits and colons, such as "0002" or "0:12:48".
    let text: String
    var size: Size = .small
    @ScaledMetric(relativeTo: .body) private var scale: CGFloat = 1

    /// "0002": `count` padded to four digits, like a real counter.
    static func countText(_ count: Int) -> String {
        let digits = String(count)
        return String(repeating: "0", count: max(0, 4 - digits.count)) + digits
    }

    /// "0:12:48": elapsed hours, minutes and seconds.
    static func timerText(_ interval: TimeInterval) -> String {
        let seconds = max(0, Int(interval))
        return String(format: "%d:%02d:%02d", seconds / 3600, seconds / 60 % 60, seconds % 60)
    }

    private var drumSize: CGSize {
        switch size {
        case .small: CGSize(width: 14 * scale, height: 24 * scale)
        case .large: CGSize(width: 26 * scale, height: 40 * scale)
        }
    }

    private static let drum = LinearGradient(
        stops: [
            .init(color: Color(rgb: 0x050506), location: 0),
            .init(color: Color(rgb: 0x2A2A2E), location: 0.28),
            .init(color: Color(rgb: 0x3B3B40), location: 0.5),
            .init(color: Color(rgb: 0x2A2A2E), location: 0.72),
            .init(color: Color(rgb: 0x050506), location: 1),
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    var body: some View {
        let drum = drumSize
        let spacing: CGFloat = size == .small ? 2 : 3
        let corner: CGFloat = size == .small ? 5 : 7
        HStack(spacing: spacing) {
            ForEach(Array(text.enumerated()), id: \.offset) { _, character in
                let isSeparator = character == ":"
                Text(String(character))
                    .font(.system(size: drum.height * 0.75, weight: .semibold).width(.condensed))
                    .monospacedDigit()
                    .foregroundStyle(Color(rgb: 0xF4F4F2))
                    .contentTransition(.numericText())
                    .frame(width: isSeparator ? drum.width * 0.5 : drum.width, height: drum.height)
                    .background {
                        if !isSeparator {
                            RoundedRectangle(cornerRadius: size == .small ? 1 : 2).fill(Self.drum)
                        }
                    }
            }
        }
        .padding(spacing + 1)
        .background(Color(rgb: 0x0D0D0F), in: .rect(cornerRadius: corner))
        .padding(size == .small ? 2 : 3)
        .background(Color(rgb: 0xC3C6CA), in: .rect(cornerRadius: corner + 2))
        .overlay(RoundedRectangle(cornerRadius: corner + 2).strokeBorder(Color(rgb: 0x7B7F85), lineWidth: 1))
        .shadow(color: .black.opacity(0.16), radius: 2, y: 1)
        .animation(.snappy, value: text)
        .accessibilityHidden(true)
    }
}
