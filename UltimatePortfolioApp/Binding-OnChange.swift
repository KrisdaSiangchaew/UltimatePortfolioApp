//
//  Binding-OnChange.swift
//  UltimatePortfolioApp
//
//  Created by Kris Siangchaew on 28/10/2563 BE.
//

import Foundation
import SwiftUI

extension Binding {
    func onChange(_ handler: @escaping () -> Void) -> Binding<Value> {
        Binding(
            get: {
                self.wrappedValue
            },
            set: { newValue in
                self.wrappedValue = newValue
                handler()
            }
        )
    }
}
