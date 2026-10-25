# SimplerLogger

The simplest way to count that something happened, or time how long it took.

Make a list of the things you keep track of, like "Watered the plants", "Took medication"
or "Walk". Each one is a counter, styled after a hand tally counter, with a single button:

- **Counting** records that it happened, stamped with the time. One tap, done.
- **Timers** start with one tap and stop with the next, recording how long it lasted.

That button works from the list itself, so most of the time you never leave the
main screen. Open a counter when you want more: its history grouped by day, editing
times, adding a note, or deleting an entry. Your counters sync between iPhone and
Apple Watch through iCloud.

## Development

- Xcode project: `SimplerLogger.xcodeproj` (schemes `SimplerLogger` and `SimplerLoggerWatch`)
- iOS 18 / watchOS 11, Swift 6, SwiftData with CloudKit
- `Shared/` is compiled into both apps: the models (`Models.swift`) and every data change (`LogStore.swift`)
- Release plan and status: [`SPEC.md`](SPEC.md)

Credits: the click sounds are cut from ["Tally Counter" by revdrmr](https://freesound.org/s/664698/) (CC0).

Possible additions:
* AI - talk to create counter (planned: Phase 6 in `SPEC.md`)
* Link to calendar
