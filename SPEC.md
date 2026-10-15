# SimplerLogger — Revival & Release Spec

Living document for reviving SimplerLogger and shipping it to the App Store.
Update the checkboxes and the session log as work progresses.

_Started: 2026-10-15_

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
- **Watch:** Uses the old WatchKit Extension two-target layout. It has its own
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
| D1 | Core Data or SwiftData | **SwiftData.** The model is tiny, and if the app has never shipped there's no user data to migrate. It removes the boilerplate and makes CloudKit sync about one line. | Open |
| D2 | Minimum OS | **iOS 18 / watchOS 11.** This allows SwiftData, `@Observable` and modern navigation. Raise to 26 if Liquid Glass or newer APIs matter. | Open |
| D3 | Phone ↔ watch sync | **CloudKit via SwiftData.** It's simplest and also gives backup and multi-device sync. WatchConnectivity is the alternative if iCloud should be avoided. | Open |
| D4 | Watch target structure | **Migrate to a single-target watch app.** The WatchKit Extension layout is deprecated. | Open |
| D5 | Complication | **Replace ClockKit with a WidgetKit widget** (e.g. a running timer or "tap to log"). This could also wait until after v1. | Open |
| D6 | Naming | **"SimplerLogger" everywhere.** Rename the folders and targets to match. Check the App Store name is available. | Open |
| D7 | Was v1 ever released under this bundle ID? | If yes, D1 needs a data migration path. | Open (ask David) |
| D8 | v1 scope | Proposed for v1: logs, tap entries, interval entries, notes, editing, reordering, watch quick-log. Deferred: home-screen quick actions, export, stats/charts, notifications. | Open |

## Known bugs and problems found in review

Severity: 🔴 crash/data loss/won't build · 🟠 wrong behavior · 🟡 cleanup

- 🔴 `LogView.swift`: passes `viewModel.name` and `viewModel.usesIntervals` to
  `UpdateLogView`, which now takes `@Binding`. This most likely **doesn't compile**
  (needs `$viewModel.name`). To be confirmed by a build.
- 🔴 `LogViewModel.add()`: `createNewEntry()` uses `startDate`, which is `nil`
  unless an interval was started earlier, so new entries can have a `nil` start.
  `LogEntity.createGrouping()` then force-unwraps `entry.start!` and **crashes**.
- 🔴 `LogViewModel.init`: `EntryEntity()` is created without a context. That's an
  invalid managed object and can crash if it's ever touched.
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

## Plan

### Phase 0: Stabilize the baseline
- [ ] Commit the current WIP to a `revive-wip` branch as-is
- [ ] Build both schemes with the current Xcode and record the errors and warnings here
- [ ] Get the iOS app compiling and launching in the simulator (minimal fixes only)
- [ ] Answer D1–D8

### Phase 1: Project modernization
- [ ] Finish the SimplerLogger rename (folders, targets, test bundle IDs) (D6)
- [ ] Set one deployment target per platform (D2) and Swift 6 language mode
- [ ] Convert the watch app to a single target (D4)
- [ ] Delete dead code and template tests

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
- [ ] Entry delete in the details view; live-updating grouped list
- [ ] Localized dates/durations; a live running timer for open intervals
- [ ] Empty states, error UI, accessibility (VoiceOver labels, Dynamic Type)
- [ ] Home-screen quick action (or remove it) (D8)

### Phase 4: Watch
- [ ] Watch list backed by synced data; one-tap log/start/stop
- [ ] WidgetKit complication (D5), if in v1

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
