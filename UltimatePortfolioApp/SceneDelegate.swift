//
//  SceneDelegate.swift
//  UltimatePortfolioApp
//
//  Created by Krisda on 13/6/2564 BE.
//

import SwiftUI

/// Handle callbacks just for the current scene
class SceneDelegate: NSObject, UIWindowSceneDelegate {
    @Environment(\.openURL) var openURL
    
    /// This will be handed the application shortcut that has been triggered.
    /// It is our job to call the associated completion handler.
    /// We use openURL() on it to have iOS load it in the current scene.
    func windowScene(
        _ windowScene: UIWindowScene,
        performActionFor shortcutItem: UIApplicationShortcutItem,
        completionHandler: @escaping (Bool) -> Void
    ) {
        guard let url = URL(string: shortcutItem.type) else {
            completionHandler(false)
            return
        }
        
        openURL(url, completion: completionHandler)
    }
    
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        if let shortcutItem = connectionOptions.shortcutItem {
            guard let url = URL(string: shortcutItem.type) else {
                return
            }
            
            openURL(url)
        }
    }
}
