//
//  UltimatePortfolioAppApp.swift
//  UltimatePortfolioApp
//
//  Created by Kris Siangchaew on 23/10/2563 BE.
//

import SwiftUI

@main
struct UltimatePortfolioAppApp: App {
    @StateObject var dataController: DataController
    @StateObject var unlockManager: UnlockManager

    init() {
        let dataController = DataController()
        let unlockManager = UnlockManager(dataController: dataController)
        _dataController = StateObject(wrappedValue: dataController)
        _unlockManager = StateObject(wrappedValue: unlockManager)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .environmentObject(dataController)
                .environmentObject(unlockManager)
                .onReceive(
                    // Automatically save when we detect that we are no longer
                    // the foreground app. Use this rather than the scene phase
                    // API so we can port to macOS, where scene phase won't detect
                    // our app losing focus as of macOS 11.1.
                    NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification),
                    perform: save
                )
        }
    }

    func save(_ notification: Notification) {
        dataController.save()
    }
}
