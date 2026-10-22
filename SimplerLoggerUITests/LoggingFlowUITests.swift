//
//  LoggingFlowUITests.swift
//  SimplerLoggerUITests
//

import XCTest

/// The core promise end to end: make a counter, then count with one tap from the list.
@MainActor
final class LoggingFlowUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    private func launch() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-UITestInMemoryStore"]
        app.launch()
        return app
    }

    /// The sheet's Done, not the keyboard's.
    private func doneButton(in app: XCUIApplication) -> XCUIElement {
        app.navigationBars["New Counter"].buttons["Done"]
    }

    func testMakeACounterAndTapToCountFromTheList() throws {
        let app = launch()
        app.buttons["Make Your First Counter"].tap()
        let name = app.textFields["Name"]
        XCTAssertTrue(name.waitForExistence(timeout: 2))
        XCTAssertFalse(doneButton(in: app).isEnabled, "Done should wait for a name")
        name.typeText("Water plants")
        doneButton(in: app).tap()

        app.buttons["Count Water plants"].tap()
        app.buttons["Count Water plants"].tap()
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH '2 today'")).firstMatch.waitForExistence(timeout: 2))

        app.staticTexts["Water plants"].tap()
        XCTAssertTrue(app.staticTexts["Today"].waitForExistence(timeout: 2))
        app.buttons["Count Water plants"].tap()
        XCTAssertTrue(app.staticTexts["3 counts"].waitForExistence(timeout: 2))
    }

    /// A real counter counts when the plunger comes back up, however long it was held.
    func testHoldingTheCapCountsOnRelease() throws {
        let app = launch()
        app.buttons["Make Your First Counter"].tap()
        app.textFields["Name"].typeText("Water plants")
        doneButton(in: app).tap()

        app.buttons["Count Water plants"].press(forDuration: 1.5)
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH '1 today'")).firstMatch.waitForExistence(timeout: 2))

        app.staticTexts["Water plants"].tap()
        XCTAssertTrue(app.staticTexts["Today"].waitForExistence(timeout: 2))
        app.buttons["Count Water plants"].press(forDuration: 1.5)
        XCTAssertTrue(app.staticTexts["2 counts"].waitForExistence(timeout: 2))
    }

    func testTimerStartsAndStops() throws {
        let app = launch()
        app.buttons["Make Your First Counter"].tap()
        app.textFields["Name"].typeText("Reading")
        let timer = app.buttons["Starts or stops a timer"]
        timer.tap()
        XCTAssertTrue(timer.isSelected)
        doneButton(in: app).tap()

        app.buttons["Start Reading timer"].tap()
        XCTAssertTrue(app.buttons["Stop Reading timer"].waitForExistence(timeout: 2))
        app.buttons["Stop Reading timer"].tap()
        XCTAssertTrue(app.buttons["Start Reading timer"].waitForExistence(timeout: 2))
    }

    func testDeletingAnEntryAndALogAsksFirst() throws {
        let app = launch()
        app.buttons["Make Your First Counter"].tap()
        app.textFields["Name"].typeText("Water plants")
        doneButton(in: app).tap()
        app.buttons["Count Water plants"].tap()
        app.buttons["Count Water plants"].tap()

        // From the entry screen, which has to close itself after deleting its own entry.
        app.staticTexts["Water plants"].tap()
        app.buttons.matching(NSPredicate(format: "label MATCHES %@", ".*[AP]M.*")).firstMatch.tap()
        app.buttons["Delete Entry"].tap()
        app.popovers.buttons["Delete Entry"].tap()
        XCTAssertTrue(app.staticTexts["1 count"].waitForExistence(timeout: 2))

        app.navigationBars.buttons["BackButton"].tap()
        app.staticTexts["Water plants"].swipeLeft()
        app.buttons["Delete"].tap()
        app.buttons["Delete Counter"].tap()
        XCTAssertTrue(app.buttons["Make Your First Counter"].waitForExistence(timeout: 2))
    }
}
