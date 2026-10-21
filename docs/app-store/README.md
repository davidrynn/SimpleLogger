# App Store submission kit

Everything App Store Connect asks for, ready to paste. Not published to GitHub Pages
(excluded in `docs/_config.yml`).

## Listing

| Field | Value | Limit |
|---|---|---|
| Name | SimplerLogger (**check availability** when creating the app record) | 30 |
| Subtitle | Log anything with one tap | 30 (25 used) |
| Primary category | Productivity | |
| Secondary category | Lifestyle | |
| Age rating | 4+ (answer "None" to every content question) | |
| Price | Free | |
| Copyright | 2026 David Rynn | |
| Privacy Policy URL | https://davidrynn.github.io/SimpleLogger/privacy.html | |
| Support URL | https://davidrynn.github.io/SimpleLogger/support.html | |
| Marketing URL (optional) | https://davidrynn.github.io/SimpleLogger/ | |

The URLs work once GitHub Pages is on: repo **Settings → Pages → Deploy from a branch →
`main` / `/docs`**.

**Keywords** (95 of 100 characters; don't repeat words already in the name or subtitle):

```
tracker,habit,counter,tally,timer,stopwatch,routine,journal,water,medication,chores,daily,count
```

**Promotional text** (170 max; can be changed without a new version):

```
Count it or time it with a single tap, from your iPhone or your wrist.
```

**Description** (4,000 max):

```
SimplerLogger is the simplest way to keep track of the little things.

Make a log for anything you want to count or time: watering the plants, taking a vitamin, feeding the cat, reading, a walk. Then just tap its button. That's it — no forms, no categories, no fuss.

ONE TAP TO LOG
Each log has its own button right on the list. Tap it to record that something happened, with the time.

ONE TAP TO TIME
Turn on Timer for things that take a while. Tap once to start and again to stop. A running timer shows in red with the time ticking, so you can't miss it.

LOOK BACK WHEN YOU WANT
Open a log to see its history by day, with totals. Fix a time, add a note, or delete an entry.

ON YOUR WRIST
The Apple Watch app puts every log one tap away, with the same button and the same running timer.

PRIVATE BY DESIGN
No account, no ads, no tracking. Your logs stay on your devices and in your own iCloud, where only you can see them.
```

**What's New** (first version): `First release.`

## App Privacy ("nutrition label")

Choose **Data Not Collected**. The app has no analytics or third-party code, and logs sync
only through the user's private iCloud database, which the developer can't access. This
matches `Shared/PrivacyInfo.xcprivacy`. If analytics, crash reporting or any SDK is added
later, update both.

## App Review notes

```
No account or sign-in is needed. Tap "Make Your First Log", name it, and tap its button on the list to log it. Turn on Timer to start and stop a timer instead. The Apple Watch app shows the same logs (synced through the user's iCloud account) and logs with one tap; logs are created on iPhone.
```

## Screenshots

| Set | Size | Files |
|---|---|---|
| iPhone 6.9" (required; App Store scales it to smaller iPhones) | 1320 × 2868 | `screenshots/iphone-6.9/` |
| Apple Watch (Series 10, 46mm) | 416 × 496 | `screenshots/watch-46mm/` |

They use the Debug-only sample data (`-SeedSampleData`). To regenerate the iPhone set
after a UI change (on an iPhone 17 Pro Max simulator, light mode, status bar set to the
current time so it matches the sample entries):

```sh
SIM=<iPhone 17 Pro Max simulator UDID>
OUT="$PWD/docs/app-store/screenshots/iphone-6.9"
xcrun simctl boot $SIM; xcrun simctl ui $SIM appearance light
xcrun simctl status_bar $SIM override --time "$(date +%-I:%M)" --batteryState charged \
  --batteryLevel 100 --cellularMode active --cellularBars 4 --wifiBars 3 --dataNetwork wifi
TEST_RUNNER_SCREENSHOT_DIR="$OUT" xcodebuild test -project SimplerLogger.xcodeproj \
  -scheme SimplerLogger -destination "id=$SIM" \
  -only-testing:SimplerLoggerUITests/AppStoreScreenshots
```

Watch: build the `SimplerLoggerWatch` scheme for a watch simulator, install it, then

```sh
xcrun simctl launch $WATCH edu.davidrynn.SimplerLogger.watchkitapp -SeedSampleData
xcrun simctl io $WATCH screenshot docs/app-store/screenshots/watch-46mm/1-list.png
```
