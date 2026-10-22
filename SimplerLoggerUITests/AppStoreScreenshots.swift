//
//  AppStoreScreenshots.swift
//  SimplerLoggerUITests
//

import XCTest

/// Captures the App Store screenshots from sample data. Skipped unless `SCREENSHOT_DIR` is set, so normal
/// test runs don't pay for it. See `docs/app-store/README.md` for the command. `SCREENSHOT_LAUNCH_ARGS`
/// (space-separated) adds launch arguments, such as a content size category for checking Large text.
@MainActor
final class AppStoreScreenshots: XCTestCase {
    func testCaptureScreenshots() throws {
        guard let directory = ProcessInfo.processInfo.environment["SCREENSHOT_DIR"], !directory.isEmpty else {
            throw XCTSkip("Set SCREENSHOT_DIR (TEST_RUNNER_SCREENSHOT_DIR for xcodebuild) to capture screenshots.")
        }
        let app = XCUIApplication()
        let extraArguments = ProcessInfo.processInfo.environment["SCREENSHOT_LAUNCH_ARGS"]?
            .split(separator: " ").map(String.init) ?? []
        app.launchArguments = ["-SeedSampleData"] + extraArguments
        app.launch()

        /// Waits for animations to finish, then saves the screen as `<directory>/<name>.png`.
        func capture(_ name: String) throws {
            sleep(2)
            let url = URL(fileURLWithPath: directory).appendingPathComponent("\(name).png")
            try app.screenshot().pngRepresentation.write(to: url)
        }

        XCTAssertTrue(app.staticTexts["Water plants"].waitForExistence(timeout: 5))
        try capture("1-list")

        app.staticTexts["Reading"].tap()
        try capture("2-timer-running")
        app.navigationBars.buttons["BackButton"].tap()

        app.staticTexts["Water plants"].tap()
        try capture("3-history")
        app.navigationBars.buttons["BackButton"].tap()

        app.buttons["New Counter"].tap()
        app.textFields["Name"].typeText("Took a walk")
        app.buttons["Starts or stops a timer"].tap()
        try capture("4-new-counter")
    }
}
