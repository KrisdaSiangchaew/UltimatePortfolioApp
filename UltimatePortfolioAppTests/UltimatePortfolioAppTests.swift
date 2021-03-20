//
//  UltimatePortfolioAppTests.swift
//  UltimatePortfolioAppTests
//
//  Created by Kris Siangchaew on 28/1/2564 BE.
//

import CoreData
import XCTest
@testable import UltimatePortfolioApp

class BaseTestCase: XCTestCase {
    var dataController: DataController!
    var managedObjectContext: NSManagedObjectContext!

    override func setUpWithError() throws {
        dataController = DataController(inMemory: true)
        managedObjectContext = dataController.container.viewContext
    }
}
