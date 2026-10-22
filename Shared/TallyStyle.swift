//
//  TallyStyle.swift
//  SimplerLogger
//

import SwiftUI
#if os(iOS)
import AudioToolbox
import UIKit
#elseif os(watchOS)
import WatchKit
#endif

// The look of a hand tally counter: a flat metal cap you press, and a dark window of white drum digits.
// Used on iPhone and watch. Only these accents are themed; everything else stays system-native.

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

/// The two clicks of a real counter, one as the cap goes down and one as the spring brings it back up.
/// On iPhone each is a haptic tap, firm then light, with a sound (`TallyClickSound`). On the watch only the
/// first clicks, because the row plays a start, stop or success haptic when its action runs (`WatchRow`).
@MainActor
enum TallyClick {
    /// The shortest time between the two clicks: the gap in the recording the sounds come from.
    static let minimumGap: Duration = .milliseconds(200)

    #if os(iOS)
    private static let pressHaptic = UIImpactFeedbackGenerator(style: .heavy)
    private static let releaseHaptic = UIImpactFeedbackGenerator(style: .light)
    #endif

    static func playPress() {
        #if os(iOS)
        pressHaptic.impactOccurred()
        TallyClickSound.playPress()
        releaseHaptic.prepare()
        #else
        WKInterfaceDevice.current().play(.click)
        #endif
    }

    static func playRelease() {
        #if os(iOS)
        releaseHaptic.impactOccurred(intensity: 0.7)
        TallyClickSound.playRelease()
        #endif
    }
}

#if os(iOS)
/// The press and release sounds, cut from a recording of a real counter by `scripts/cut_tally_clicks.py`:
/// three takes of each, picked at random so repeated taps don't sound identical. Played as system sounds, so they start without delay,
/// follow the alert volume, and are silent when the ring/silent switch is on silent.
enum TallyClickSound {
    private static let presses = (1...3).map { load("TallyPress\($0)") }
    private static let releases = (1...3).map { load("TallyRelease\($0)") }

    static func playPress() { play(presses.randomElement()!) }
    static func playRelease() { play(releases.randomElement()!) }

    private static func play(_ sound: SystemSoundID) {
        if sound != 0 { AudioServicesPlaySystemSound(sound) }
    }

    /// 0 (plays nothing) if the file is missing.
    private static func load(_ name: String) -> SystemSoundID {
        var sound: SystemSoundID = 0
        if let url = Bundle.main.url(forResource: name, withExtension: "caf") {
            AudioServicesCreateSystemSoundID(url as CFURL, &sound)
        }
        return sound
    }
}
#endif

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
