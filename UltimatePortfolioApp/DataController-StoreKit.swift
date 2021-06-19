//
//  DataController-StoreKit.swift
//  UltimatePortfolioApp
//
//  Created by Krisda on 19/6/2564 BE.
//

import StoreKit

extension DataController {
    // swiftlint:disable:next line_length
    /// Finding the first active scene (that's the one currently receiving the user input), then asking for a review prompt to appear there
    func appLaunched() {
        guard count(for: Project.fetchRequest()) >= 5 else { return }
        
            let allScenes = UIApplication.shared.connectedScenes
            let scene = allScenes.first { $0.activationState == .foregroundActive }

            if let windowScene = scene as? UIWindowScene {
                SKStoreReviewController.requestReview(in: windowScene)
            }
    }
}
