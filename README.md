# SimplerLogger

The simplest way to log that something happened, or how long it took.

Make a list of the things you track, like "Watered the plants", "Took medication" or
"Walk". Each one is a log, and each log has a single button:

- **Tap logs** record that it happened, stamped with the time. One tap, done.
- **Timer logs** start with one tap and stop with the next, recording how long it lasted.

That button works from the list itself, so most of the time you never leave the
main screen. Open a log when you want more: its history grouped by day, editing
times, adding a note, or deleting an entry. Your logs sync between iPhone and
Apple Watch through iCloud.

## Development

- Xcode project: `SimplerLogger.xcodeproj` (schemes `SimplerLogger` and `SimplerLoggerWatch`)
- iOS 18 / watchOS 11, Swift 6, SwiftData with CloudKit
- `Shared/` is compiled into both apps: the models (`Models.swift`) and every data change (`LogStore.swift`)
- Release plan and status: [`SPEC.md`](SPEC.md)
