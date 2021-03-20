//
//  UltimatePortfolioAppUITests.swift
//  UltimatePortfolioAppUITests
//
//  Created by Kris Siangchaew on 20/3/2564 BE.
//

import XCTest

class UltimatePortfolioAppUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        app = XCUIApplication()
        app.launchArguments = ["enable-testing"]
        app.launch()
    }

    func testAppHas4Tabs() throws {
        XCTAssertEqual(app.tabBars.buttons.count, 4, "There should be 4 tabs in the app.")
    }

    func testOpenTabAddsItems() throws {
        app.buttons["Open"].tap()
        XCTAssertEqual(app.tables.cells.count, 0, "There should be 0 rows at launch.")

        let tapCounts = 5
        for _ in 1...tapCounts {
            app.buttons["add"].tap()
        }
        XCTAssertEqual(app.tables.cells.count, tapCounts, "There should be \(tapCounts) rows in the table")
    }

    func testEditProjectName() throws {
        app.buttons["Open"].tap()

        app.buttons["add"].tap()
        XCTAssertEqual(app.tables.cells.count, 1, "There should 1 new project row created")

        app.buttons["NEW PROJECT"].tap()

        app.textFields["New Project"].tap()
        app.keys["space"].tap()
        app.keys["more"].tap()
        app.keys["2"].tap()
        app.buttons["Return"].tap()

        app.buttons["Open Projects"].tap()

        // Work around since modified project name cannot be
        // found right after coming back from editing
        app.buttons["NEW PROJECT 2"].tap()
        app.buttons["Open Projects"].tap()

        XCTAssertTrue(app.buttons["NEW PROJECT 2"].exists, "The new project name should exist.")
    }

    func testAddingProjectInsertRow() throws {
        app.buttons["Open"].tap()
        XCTAssertEqual(app.tables.cells.count, 0, "There should be 0 new project row created.")

        app.buttons["add"].tap()
        XCTAssertEqual(app.tables.cells.count, 1, "There should be 1 new project row created.")

        app.buttons["Add New Item"].tap()
        XCTAssertEqual(app.tables.cells.count, 2, "There should be 2 item created.")
    }

    func testEditingItemUpdateCorrectly() throws {
        try testAddingProjectInsertRow()

        app.buttons["New Item"].tap()
        app.textFields["New Item"].tap()
        app.keys["space"].tap()
        app.keys["more"].tap()
        app.keys["2"].tap()
        app.buttons["Return"].tap()

        app.buttons["Open Projects"].tap()

        XCTAssertTrue(app.buttons["New Item 2"].exists, "The new item name should exist.")
    }

    func testAllAwardsShowLockAlert() throws {
        app.buttons["Awards"].tap()

        for award in app.scrollViews.buttons.allElementsBoundByIndex {
            award.tap()
            XCTAssertTrue(app.alerts["Locked"].exists, "Alert to say award is lock should be shown for all awards.")
        }
    }
}
