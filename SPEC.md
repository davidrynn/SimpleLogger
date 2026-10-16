# SimplerLogger — Revival & Release Spec

Living document for reviving SimplerLogger and shipping it to the App Store.
Update the checkboxes and the session log as work progresses.

_Started: 2026-10-15 · Decisions D1–D8 settled 2026-10-15_

## Goal

Ship SimplerLogger, a fast way to log "this happened" (a tap) or "this lasted
this long" (start/stop interval) across any number of named logs, on iPhone,
with a companion Apple Watch app.

## Current state (as of 2026-10-15)

Originally written May–June 2022; `LogViewModel` added April 2024. ~1,300 lines
of Swift.

- **Persistence:** Core Data is mostly wired up, not just started. There are two
  entities: `LogEntity` (name, usesIntervals, index, entries) and `EntryEntity`
  (start, end, intervalStarted, note). The views use `@FetchRequest` and a shared
  `viewContext`. The plain `Log` and `Entry` structs aren't used.
- **iOS screens:** `MainView` (list of logs, add/reorder/delete, quick-add button
  on each row) → `LogView` (entries grouped by day, add/start/stop) →
  `EntryDetailsView` (edit start/stop/note). `NewLogView` and `UpdateLogView`
  are sheets.
- **Architecture:** Halfway through moving `LogView` logic into `LogViewModel`
  (there are large commented-out blocks). The same add/stop logic is duplicated
  in `MainView`, `LogViewModel`, `DataController` and the watch `MainView`.
- **Watch:** ~~Uses the old WatchKit Extension two-target layout.~~ (Wrong: it was already a single target; only a folder was misnamed. Fixed in Phase 1.) It has its own
  `MainView`/`WatchRow`, but **no Core Data stack and no sync with the phone**,
  so it can't show any data. The ClockKit complication and notification
  controller are untouched template code.
- **Project:** A half-done rename from SimpleLogger to SimplerLogger. The project
  file, schemes and product are SimplerLogger, but the source folders are still
  `SimpleLogger*`. Deployment targets are mixed (iOS 15.4 and 16.1; watchOS 8.5
  and 10.4). Bundle ID is `edu.davidrynn.SimplerLogger`.
- **Tests:** Template code only.
- **Git:** Lots of uncommitted work (staged and unstaged) on `main`.

## Decisions

| # | Decision | Recommendation | Status |
|---|----------|----------------|--------|
| D1 | Core Data or SwiftData | **SwiftData.** No shipped users (D7), so there's nothing to migrate. | ✅ SwiftData |
| D2 | Minimum OS | **iOS 18 / watchOS 11.** | ✅ iOS 18 / watchOS 11 |
| D3 | Phone ↔ watch sync | **CloudKit via SwiftData.** Also gives backup and multi-device sync. | ✅ CloudKit |
| D4 | Watch target structure | **Single-target watch app.** | ✅ Single target |
| D5 | Complication | Delete the ClockKit template now; WidgetKit widget after v1. | ✅ Deferred to post-v1 |
| D6 | Naming | **"SimplerLogger" everywhere.** Rename folders and targets. Still need to check App Store name availability. | ✅ SimplerLogger |
| D7 | Was v1 ever released under this bundle ID? | Never released, so no migration path is needed. | ✅ Never released |
| D8 | v1 scope | **In:** logs, tap entries, interval entries, notes, editing, reordering, watch quick-log. **Out (post-v1):** home-screen quick action (remove the registered one), export, stats/charts, notifications. | ✅ Decided |

## Known bugs and problems found in review

Severity: 🔴 crash/data loss/won't build · 🟠 wrong behavior · 🟡 cleanup

- 🔴 `LogView.swift:129`: passes `viewModel.name` and `viewModel.usesIntervals` to
  `UpdateLogView`, which now takes `@Binding`. **Confirmed build error** (needs
  `$viewModel.name`).
- 🔴 `LogViewModel.add()`: `createNewEntry()` uses `startDate`, which is `nil`
  unless an interval was started earlier, so new entries can have a `nil` start.
  `LogEntity.createGrouping()` then force-unwraps `entry.start!` and **crashes**.
  **Confirmed** (`Extensions.swift:42`). Because `MainView` builds a `LogViewModel`
  for every row, the bad entry is saved and **the app crashes on every launch**
  after that.
- 🔴 `LogViewModel.init`: `EntryEntity()` is created without a context. That's an
  invalid managed object and can crash if it's ever touched. **Confirmed** at
  runtime: `Failed to call designated initializer on NSManagedObject class 'EntryEntity'`.
- 🔴 Deleting a log uses the Nullify rule, and `LogViewModel.delete` only removes
  entries from the relationship. Either way, **orphaned entries pile up** in the
  store. It should be Cascade plus `moc.delete`.
- 🟠 `LogViewModel.started` is set from `log.usesIntervals` rather than from
  whether an interval is open. `LogView` also keeps its own `@State started`
  that never syncs, so the Start/Stop state is wrong after navigating away.
- 🟠 `entriesGrouping` is computed once in `init` and never refreshed, so the
  list doesn't update after add, edit or delete. This is the README TODO "editing
  doesn't update right".
- 🟠 `LogViewModel` is created inside `MainView.body` on every render. It should
  be owned by the view (`@StateObject`/`@State`).
- 🟠 Edits made in `UpdateLogView` go through `onChange` on the view model, which
  is fragile. Save explicitly on Done.
- 🟠 The trash button in `EntryDetailsView` only dismisses. It doesn't delete.
- 🟠 New logs are always created with `index = 0`, so ordering is undefined
  until the user reorders.
- 🟠 `MainRow` copies `name` and `didStart` into `@State` from init parameters,
  so it doesn't reflect later changes. Its inline name `TextField` never saves.
- 🟠 The watch app has no data at all (see Current state).
- 🟠 The home-screen quick action "New Entry" is registered but never handled.
- 🟡 `DataController` declares a `@FetchRequest`, which doesn't work outside a
  view and is unused. `updateEntry`/`deletefromLog` are empty stubs.
- 🟡 `fatalError` when the store fails to load. Replace it with recovery or an
  error UI before release.
- 🟡 Errors are shown as raw `debugDescription` text.
- 🟡 Dead code: the `Log`/`Entry` structs, big commented-out blocks,
  `getSectionText`, and the retroactive `Comparable` conformance on
  `DateComponents`.
- 🟡 Deprecated APIs: `NavigationView`, `navigationBarItems`,
  `navigationBarTitle`, single-parameter `onChange`, `PreviewProvider`.
- 🟡 Date section headers use the raw `yyyy-MM-dd` key instead of localized dates.

## Design review

The full write-up, with screenshots, is in
[`docs/design-review-2026-10-15.md`](docs/design-review-2026-10-15.md).
Its fixes are tracked as Phase 3 tasks below.

## Plan

### Phase 0: Stabilize the baseline
- [x] Commit the current WIP to a `revive-wip` branch as-is (7ccf763)
- [x] Build with the current Xcode and record the errors and warnings here
  - The `SimplerLogger` scheme (iPhone 17 simulator, iOS 27) also builds the embedded watch app.
  - **2 errors**, both at `LogView.swift:129`: `UpdateLogView` is passed a `String`/`Bool`
    where it expects `Binding<String>`/`Binding<Bool>`.
  - **8 warnings:**
    - Missing `import CoreData` in `NewLogView`, `EntryDetailsView`, `LogView` and the
      watch `MainView`. In the watch `MainView` this becomes an error in Swift 6 mode.
    - Deprecated `onChange(of:perform:)` in `SimpleLoggerApp` and the watch `MainView`.
    - The retroactive `Comparable` conformance on `DateComponents` in `Extensions.swift`.
- [x] Get the iOS app compiling and launching in the simulator (minimal fixes only)
  - Fixed `LogView.swift:129` to pass `$viewModel.name`/`$viewModel.usesIntervals`.
    It now builds with 4 warnings and launches on a fresh install.
  - Smoke test: creating a log ✅, quick-add from a row ✅, opening a log ✅.
    **Tapping Add inside a log crashes** (see the bugs list), and from then on
    **the app crashes on every launch**.
- [x] Fix the Add crash and make grouping tolerate a `nil` start, so existing bad data can't brick the app
  - `add()`/`startInterval()` now stamp `start` with the current date (`startInterval` had the same bug: it set `startDate` after creating the entry).
  - `createGrouping()` puts `nil`-start entries in a "No date" section instead of force-unwrapping.
  - `currentEntry` is now optional, which removes the context-less `EntryEntity()`.
  - `save()` refreshes `entriesGrouping`, so new entries appear immediately.
  - Verified in the simulator on the store that held the bad data: it launches, Add works, and it relaunches cleanly.
- [x] Answer D1–D8

### Phase 1: Project modernization
- [x] Finish the SimplerLogger rename (folders, targets, test bundle IDs) (D6)
  - Folders are now `SimplerLogger`, `SimplerLoggerTests`, `SimplerLoggerUITests`, `SimplerLoggerWatch`; `SimplerLoggerApp.swift`.
    Fixed `TEST_TARGET_NAME` (pointed at a nonexistent `SimpleLogger` target) and the watch display name.
  - Still named `SimpleLogger.xcdatamodel` inside the model bundle; left alone because Phase 2 deletes it.
- [x] Set one deployment target per platform (D2) and Swift 6 language mode
  - iOS 18.0 / watchOS 11.0 set once at project level (target-level overrides removed); `SWIFT_VERSION = 6.0` for every target.
    Verified in the build log. It compiled with no Swift 6 errors.
- [x] Convert the watch app to a single target (D4)
  - **It already was one.** `SimplerLoggerWatch` was a plain watchOS application (migrated in April 2024); only the
    "WatchKit Extension" folder name was left. Merged it into `SimplerLoggerWatch/`.
  - Deleted ClockKit/notification code, the complication asset set, the unused extension `Info.plist`, the push
    payload, and the Complication/Notification schemes (D5).
  - Deleted the `SimplerLoggerWatchTests` (no files; test host pointed at the extension that no longer exists) and
    `SimplerLoggerWatchUITests` (template only) targets and the `SimplerLoggerWatchTests` scheme.
- [x] Delete dead code and template tests
  - Removed the `Log`/`Entry` structs, commented-out blocks, `getSectionText`, `saveName`, the `DateComponents`
    `Comparable` conformance, `DataController`'s `@FetchRequest` and unused/stub methods, commented-out previews,
    and the unhandled "New Entry" quick action (D8). Added the missing `import CoreData`s.
  - Replaced the template unit test with `GroupingTests` (regression test for the `nil`-start crash). Kept the
    UI launch test (made it `@MainActor` for Swift 6). Both pass.
  - Remaining warnings: 4× deprecated `onChange(of:perform:)` (Phase 3). The test run logs Core Data's "multiple
    NSEntityDescriptions claim LogEntity" because the test loads a second copy of the model; it goes away with SwiftData.

### Phase 2: Data layer
- [ ] Implement the chosen persistence approach (D1) with one shared model/store used by iOS and watch
- [ ] Put all mutations (add, start, stop, edit, delete, reorder) in one place; remove the duplicates
- [ ] Cascade-delete entries; assign `index` correctly when creating a log
- [ ] Model "an interval is open" in a way that can't get out of sync
- [ ] Enable sync (D3)
- [ ] Unit tests for the data layer (in-memory store)

### Phase 3: iOS UI
- [ ] Fix every 🔴/🟠 bug above
- [ ] `NavigationStack`, modern toolbar APIs, `@Observable` state
- [ ] Prominent primary action (`.borderedProminent`, large, pinned to the bottom of the log screen)
- [ ] Clear running state: color, a "Stop" label and a live elapsed time; respect Reduce Motion
- [ ] "Today"/"Yesterday" section headers, short times, formatted durations
- [ ] VoiceOver labels that include the log name and running state; Dynamic Type-safe row layout
- [ ] Empty state (`ContentUnavailableView`); disable Done until the name is valid
- [ ] Confirm before deleting logs and entries
- [ ] Rebuild entry details: Start/End/Duration/Note sections, autosave, working Delete
- [ ] New/Edit Log sheets: titles, name first with keyboard focus, Cancel on Edit, footer text
- [ ] Main list edit mode: hide quick-add and chevron; working rename
- [ ] Consistent wording and capitalization
- [ ] Live-updating grouped list; error UI
- [x] Remove the unhandled home-screen quick action (D8: deferred past v1)

### Phase 4: Watch
- [ ] Watch list backed by synced data; one-tap log/start/stop
- [x] Delete the ClockKit complication template (D5: widget deferred past v1)

### Phase 5: Release prep
- [ ] App icon in every required size; launch screen
- [ ] Privacy manifest (`PrivacyInfo.xcprivacy`) and App Store privacy "nutrition label"
- [ ] Privacy policy URL; support URL
- [ ] Screenshots (iPhone + Watch), description, keywords
- [ ] UI tests for the core flows
- [ ] TestFlight beta → fix → submit

## Session log

| Date | Summary |
|------|---------|
| 2026-10-15 | Read the whole codebase and wrote this spec. Nothing built or changed yet. |
| 2026-10-15 | Committed the WIP to `revive-wip` (7ccf763). First build fails: 2 errors in `LogView.swift:129`, 8 warnings. |
| 2026-10-15 | Fixed the build error; the app builds and launches. Smoke test: tapping Add in a log crashes, and the app then crashes on every launch. |
| 2026-10-15 | Couldn't reproduce the reported constraint warning (the on-screen keyboard was unavailable to test). Did a design review of all iOS screens: `docs/design-review-2026-10-15.md`. |
| 2026-10-15 | Settled D1–D8 (all as recommended; v1 extra scope = watch quick-log only; never released). Fixed the Add crash and the launch crash from `nil`-start entries; verified in the simulator. |
| 2026-10-15 | Phase 1 done: rename finished, iOS 18 / watchOS 11, Swift 6, watch debris and broken watch test targets removed, dead code removed, regression test added. Builds clean apart from 4 deprecation warnings; 2/2 tests pass. |
