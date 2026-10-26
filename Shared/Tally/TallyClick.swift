//
//  TallyClick.swift
//  SimplerLogger
//

import SwiftUI
#if os(iOS)
import AudioToolbox
import UIKit
#elseif os(watchOS)
import WatchKit
#endif

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
