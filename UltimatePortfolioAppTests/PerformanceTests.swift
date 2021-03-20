//
//  PerformanceTests.swift
//  UltimatePortfolioAppTests
//
//  Created by Kris Siangchaew on 20/3/2564 BE.
//

import XCTest
@testable import UltimatePortfolioApp

class PerformanceTests: BaseTestCase {
    func testAwardCalculationPerformance() throws {
        // Create a significant amount of test data
        for _ in 1...100 {
            try dataController.createSampleData()
        }
        
        // Simulate lots of awards to check
        let awards = Array(repeating: Award.allAwards, count: 25).joined()
        XCTAssertEqual(awards.count, 500,
                       "This checks the awards count is constant. Change the awards count to reflect the latest value.")
        
        measure {
            _ = awards.filter(dataController.hasEarned)
        }
    }
}
