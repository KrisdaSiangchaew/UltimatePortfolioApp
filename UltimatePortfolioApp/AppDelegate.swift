//
//  AppDelegate.swift
//  UltimatePortfolioApp
//
//  Created by Krisda on 13/6/2564 BE.
//

import SwiftUI

/// Handle app-wide announcements
class AppDelegate: NSObject, UIApplicationDelegate {
    /// Create a scene configuration using whatever configuration settings were passed int,
    /// while also telling iOS to use the SceneDelegate class we created.
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let sceneConfiguration = UISceneConfiguration(name: "Default", sessionRole: connectingSceneSession.role)
        sceneConfiguration.delegateClass = SceneDelegate.self
        return sceneConfiguration
    }
}
