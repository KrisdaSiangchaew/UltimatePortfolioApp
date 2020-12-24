//
//  Sequence-Sorting.swift
//  UltimatePortfolioApp
//
//  Created by Kris Siangchaew on 11/11/2563 BE.
//

import Foundation

extension Sequence {
    func sorted<Value: Comparable>(
        by keyPath: KeyPath<Element, Value>,
        using areInIncreasingOrder: (Value, Value) throws -> Bool
    ) rethrows -> [Element] {
        try self.sorted {
            try areInIncreasingOrder($0[keyPath: keyPath], $1[keyPath: keyPath])
        }
    }

    func sorted<Value: Comparable>(by keyPath: KeyPath<Element, Value>) -> [Element] {
        self.sorted(by: keyPath, using: <)
    }
}
