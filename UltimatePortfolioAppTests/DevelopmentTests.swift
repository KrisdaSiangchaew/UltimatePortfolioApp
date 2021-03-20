//
//  DevelopmentTests.swift
//  UltimatePortfolioAppTests
//
//  Created by Kris Siangchaew on 28/1/2564 BE.
//

import XCTest
import CoreData
@testable import UltimatePortfolioApp

class DevelopmentTests: BaseTestCase {
    func testSampleDataCreationWorks() throws {
        try dataController.createSampleData()

        XCTAssertEqual(dataController.count(for: Project.fetchRequest()), 5, "There should be 5 sample projects.")
        XCTAssertEqual(dataController.count(for: Item.fetchRequest()), 50, "There should be 50 sample items.")
    }

    func testDeleteAllClearsEverything() throws {
//        try dataController.createSampleData()
        dataController.deleteAll()

        XCTAssertEqual(dataController.count(for: Project.fetchRequest()), 0, "There should be 0 sample project left.")
        XCTAssertEqual(dataController.count(for: Item.fetchRequest()), 0, "There should be 0 sample item left.")
    }

    func testExampleProjectIsClose() throws {
        let project = Project.example
        XCTAssertTrue(project.closed, "The example project should be closed.")
    }

    func testExampleItemIsHighPriority() throws {
        let item = Item.example
        XCTAssertEqual(item.priority, 3, "The example item should have priority = 3")
    }
}
