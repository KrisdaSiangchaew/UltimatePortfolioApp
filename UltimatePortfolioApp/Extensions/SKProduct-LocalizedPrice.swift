//
//  SKProduct-LocalizedPrice.swift
//  UltimatePortfolioApp
//
//  Created by Krisda on 12/6/2564 BE.
//

import StoreKit

extension SKProduct {
    var localizedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = priceLocale
        return formatter.string(from: price)!
    }
}
