# App Store submission kit

Everything App Store Connect asks for, ready to paste. Not published to GitHub Pages
(excluded in `docs/_config.yml`).

## Listing

| Field | Value | Limit |
|---|---|---|
| Name | Simpler Counter: Tally Clicker (**reserve it** by creating the app record) | 30 (30 used) |
| Subtitle | One-tap habit tracker & timer | 30 (29 used) |
| Name on the Home Screen | SimplerCounter | |
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

**Keywords** (90 of 100 characters; no spaces, and no words already in the name or subtitle):

```
count,click,tap,stopwatch,log,daily,routine,water,pill,medication,chores,record,watch,goal
```

Optional: add `,tasbih` (97 characters). Prayer-bead counting is a common use for tally apps.

### Why these words

The App Store searches the name, subtitle and keyword field (not the description), and
combines words across them, so "tally" in the name and "counter" anywhere match "tally
counter". The words come from what the top 25 US apps use in their names for each search
(checked 2026-10-21):

| Search | Most common words in top names |
|---|---|
| counter | counter (21), tally (8), count (5), tap (3) |
| tally counter | counter (23), tally (17), tap (5), click (4), tracker (3) |
| click counter | counter (21), click (10), tally (6) |
| tap counter | counter (21), tap (15), count (5) |
| habit tracker | habit (16), tracker (16), daily (4), routine (2) |

"Simpler Counter" has a space so "counter" is indexed as its own word. Before submitting,
check popularity scores for these words in Apple Search Ads and try App Store autocomplete
for "tally", "counter" and "click". After launch, App Analytics shows which searches find the
app; keywords can change with any update, but keep the name stable.

**Promotional text** (170 max; can be changed without a new version):

```
Count it or time it with a single tap, from your iPhone or your wrist.
```

**Description** (4,000 max):

```
Simpler Counter is the simplest way to keep track of the little things.

Make a counter for anything you want to count or time: watering the plants, taking a vitamin, feeding the cat, reading, a walk. Then just tap its button. That's it — no forms, no categories, no fuss.

ONE TAP TO COUNT
Each counter has its own button right on the list, like the plunger on a hand tally counter. Tap it to count that something happened, with the time.

ONE TAP TO TIME
Choose a timer for things that take a while. Tap once to start and again to stop. A running timer shows in red with the time ticking, so you can't miss it.

LOOK BACK WHEN YOU WANT
Open a counter to see its history by day, with totals. Fix a time, add a note, or delete an entry.

ON YOUR WRIST
The Apple Watch app puts every counter one tap away, with the same button and the same running timer.

PRIVATE BY DESIGN
No account, no ads, no tracking. Your counters stay on your devices and in your own iCloud, where only you can see them.
```

**What's New** (first version): `First release.`

## App Privacy ("nutrition label")

Choose **Data Not Collected**. The app has no analytics or third-party code, and counters sync
only through the user's private iCloud database, which the developer can't access. This
matches `Shared/PrivacyInfo.xcprivacy`. If analytics, crash reporting or any SDK is added
later, update both.

## App Review notes

```
No account or sign-in is needed. Tap "Make Your First Counter", name it, and tap its button on the list to count it. Under "Each tap", choose "Starts or stops a timer" to time it instead. The Apple Watch app shows the same counters (synced through the user's iCloud account) and counts with one tap; counters are created on iPhone.
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
xcrun simctl launch $WATCH edu.davidrynn.SimplerCounter.watchkitapp -SeedSampleData
xcrun simctl io $WATCH screenshot docs/app-store/screenshots/watch-46mm/1-list.png
```
