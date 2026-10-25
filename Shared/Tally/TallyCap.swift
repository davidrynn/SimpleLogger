//
//  TallyCap.swift
//  SimplerLogger
//

import SwiftUI

// The look of a hand tally counter: a flat metal cap you press, and a dark window of white drum digits.
// Used on iPhone and watch. Only these accents are themed; everything else stays system-native.

/// The counter's plunger: a flat-topped metal cap, rounded only at its edge, seen from straight on. The light
/// is even (no highlight from one side), so it reads the same in light and dark mode. It stands out by a soft
/// shadow all round; pressed, it sinks: a little smaller, a little darker, the shadow tight. Dimmer in dark mode
/// so it doesn't glare. `content` (an icon) moves with the face.
struct TallyCap<Content: View>: View {
    var diameter: CGFloat
    var isPressed: Bool
    @ViewBuilder var content: Content
    @Environment(\.colorScheme) private var colorScheme

    /// Mostly one flat tone, then a faint bright ring and a gentle roll-off at the rim.
    private func face(diameter: CGFloat) -> RadialGradient {
        let stops: [(UInt32, CGFloat)] = colorScheme == .dark
            ? [(0xC6CACE, 0), (0xC1C5C9, 0.62), (0xCDD0D4, 0.72), (0xA2A6AB, 0.85), (0x7C8086, 0.95), (0x6A6E74, 1)]
            : [(0xE6E8EB, 0), (0xE1E4E7, 0.62), (0xEEF0F2, 0.72), (0xC3C7CB, 0.85), (0x9DA1A7, 0.95), (0x8C9096, 1)]
        return RadialGradient(
            stops: stops.map { .init(color: Color(rgb: $0.0), location: $0.1) },
            center: .center,
            startRadius: 0,
            endRadius: diameter / 2
        )
    }

    var body: some View {
        let shadowOpacity = colorScheme == .dark ? 0.6 : 0.22
        Circle()
            .fill(face(diameter: diameter))
            .overlay(Circle().strokeBorder(Color(rgb: 0x5F6368).opacity(0.6), lineWidth: 1))
            .overlay { content }
            .brightness(isPressed ? -0.05 : 0)
            .scaleEffect(isPressed ? 0.94 : 1)
            .shadow(color: .black.opacity(shadowOpacity), radius: isPressed ? 0.5 : diameter * 0.06)
            .frame(width: diameter, height: diameter)
            .animation(.easeOut(duration: 0.07), value: isPressed)
    }
}

/// A button drawn as a tally cap, with its label (an icon) on the cap. For the list's one-tap buttons.
struct TallyCapButtonStyle: ButtonStyle {
    var diameter: CGFloat = 44

    func makeBody(configuration: Configuration) -> some View {
        TallyCapBody(diameter: diameter, isPressed: configuration.isPressed) { _ in
            configuration.label
        }
    }
}

/// Scales the cap with Dynamic Type, which a `ButtonStyle` can't do itself. It grows to at most 1.5 times
/// its size, so a big cap doesn't crowd out the text at accessibility sizes.
private struct TallyCapBody<Content: View>: View {
    private let baseDiameter: CGFloat
    @ScaledMetric private var scaledDiameter: CGFloat
    var isPressed: Bool
    /// Given the cap's final diameter, so an icon can size itself to it.
    var content: (CGFloat) -> Content

    init(diameter: CGFloat, isPressed: Bool, @ViewBuilder content: @escaping (CGFloat) -> Content) {
        baseDiameter = diameter
        _scaledDiameter = ScaledMetric(wrappedValue: diameter, relativeTo: .title3)
        self.isPressed = isPressed
        self.content = content
    }

    var body: some View {
        let diameter = min(scaledDiameter, baseDiameter * 1.5)
        TallyCap(diameter: diameter, isPressed: isPressed) { content(diameter) }
            .contentShape(Circle())
            .modifier(TallyClickFeedback(isPressed: isPressed))
    }
}

/// Clicks as the cap goes down and again as it comes back up (`TallyClick`). A quick tap can lift before the
/// first click has finished, so the second never comes sooner than `TallyClick.minimumGap` after the first;
/// held longer, it waits for the finger to lift, like a real counter.
private struct TallyClickFeedback: ViewModifier {
    var isPressed: Bool
    @State private var pressedAt: ContinuousClock.Instant?

    func body(content: Content) -> some View {
        content
            .onChange(of: isPressed) { _, pressed in
                if pressed {
                    pressedAt = .now
                    TallyClick.playPress()
                } else if let pressedAt {
                    self.pressedAt = nil
                    let wait = TallyClick.minimumGap - (ContinuousClock.now - pressedAt)
                    Task {
                        if wait > .zero { try? await Task.sleep(for: wait) }
                        TallyClick.playRelease()
                    }
                }
            }
    }
}

/// A button whose whole label is the target, with a tally cap beside the label that presses with it.
/// For the watch rows (cap trailing) and the log screen's bottom button (cap leading).
struct TallyCapRowButtonStyle: ButtonStyle {
    var symbol: String
    var symbolColor: Color = .tallyInk
    var diameter: CGFloat
    var capEdge: HorizontalEdge
    var spacing: CGFloat = 8

    func makeBody(configuration: Configuration) -> some View {
        let cap = TallyCapBody(diameter: diameter, isPressed: configuration.isPressed) { diameter in
            Image(systemName: symbol)
                .font(.system(size: diameter * 0.42, weight: .bold))
                .foregroundStyle(symbolColor)
                .contentTransition(.symbolEffect(.replace))
        }
        HStack(spacing: spacing) {
            if capEdge == .leading { cap }
            configuration.label
            if capEdge == .trailing { cap }
        }
        .contentShape(Rectangle())
    }
}
