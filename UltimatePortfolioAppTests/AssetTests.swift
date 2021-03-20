//
//  AssetTests.swift
//  UltimatePortfolioAppTests
//
//  Created by Kris Siangchaew on 28/1/2564 BE.
//

import XCTest
@testable import UltimatePortfolioApp

class AssetTests: XCTestCase {

    func testColorsExist() {
        for color in Project.colors {
            XCTAssertNotNil(UIColor(named: color), "Failed to load color '\(color)' from asset catalog")
        }
    }

    func testJSONLoadsCorrectly() {
        XCTAssertTrue(Award.allAwards.isEmpty == false, "Failed to load awards from JSON")
    }
}
