//
//  ExtensionTests.swift
//  UltimatePortfolioAppTests
//
//  Created by Kris Siangchaew on 18/2/2564 BE.
//

import SwiftUI
import XCTest
@testable import UltimatePortfolioApp

class ExtensionTests: BaseTestCase {
    func testSequenceKeyPathSortingSelf() {
        let items = [2, 4, 1, 3]
        let sortedItems = items.sorted(by: \.self)

        XCTAssertEqual(sortedItems, [1, 2, 3, 4], "Output should be in ascending order.")
    }

    func testSequenceKeyPathSortingCustom() {
        // Given
        struct Example: Equatable {
            let value: Int
            let name: String

            static func < (lhs: Example, rhs: Example) -> Bool {
                lhs.value < rhs.value
            }
        }

        let examples: [Example] = [
            Example(value: 3, name: "Three"),
            Example(value: 1, name: "One"),
            Example(value: 2, name: "Two")
        ]

        // When
        let sortedExamples = examples.sorted(by: \.self) {
            $0.value < $1.value
        }

        // Then
        XCTAssertEqual(sortedExamples.map { $0.name }, ["One", "Two", "Three"], "Output name in ascending order")
    }

    func testBundleDecodeString() {
        let bundle = Bundle(for: ExtensionTests.self)

        let decoded = bundle.decode(String.self, from: "DecodableString.json")

        XCTAssertEqual(decoded, "Hello my friend.", "Output should equal content of DecodableString.json")
    }

    func testBundleDecodeDictionary() {
        // Given
        let bundle = Bundle(for: ExtensionTests.self)

        // When
        let decoded = bundle.decode([String: Int].self, from: "DecodableDictionary.json")

        // Then
        XCTAssertEqual(decoded.count, 2, "Output should contain same amount of items in DecodableDictionary.json")
        XCTAssertEqual(decoded, ["1": 1, "2": 2], "Output should equal content of DecodableDictionary.json")
    }
    
    func testBindingOnChange() {
        var onChangeFunctionRun = false
        
        func exampleFunctionRun() {
            onChangeFunctionRun = true
        }
        
        var storedValue = ""
        
        let binding = Binding(
            get: {
                storedValue
            },
            set: {
                storedValue = $0
            }
        )
        
        let changedBinding = binding.onChange(exampleFunctionRun)

        // When
        changedBinding.wrappedValue = "Test"
        
        // Then
        XCTAssertTrue(onChangeFunctionRun, "Output should be true when exampleFunctionRun() is called.")
    }
}
