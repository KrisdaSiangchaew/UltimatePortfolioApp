//
//  ProjectTests.swift
//  UltimatePortfolioAppTests
//
//  Created by Kris Siangchaew on 28/1/2564 BE.
//

import XCTest
import CoreData
@testable import UltimatePortfolioApp

class ProjectTests: BaseTestCase {

    func testCreatingProjectsAndItems() {
        let itemCount = 10

        for _ in 0..<itemCount {
            let project = Project(context: managedObjectContext)

            for _ in 0..<itemCount {
                let item = Item(context: managedObjectContext)
                item.project = project
            }
        }
        XCTAssertEqual(dataController.count(for: Project.fetchRequest()), itemCount)
        XCTAssertEqual(dataController.count(for: Item.fetchRequest()), itemCount * itemCount)
    }

    func testDeletingProjectCascadeDeletesItems() throws {
        try dataController.createSampleData()

        let request = NSFetchRequest<Project>(entityName: "Project")
        let projects = try managedObjectContext.fetch(request)

        dataController.delete(projects[0])

        XCTAssertEqual(dataController.count(for: Project.fetchRequest()), 4)
        XCTAssertEqual(dataController.count(for: Item.fetchRequest()), 40)
    }
}
