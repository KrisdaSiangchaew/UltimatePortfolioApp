//
//  ContentView.swift
//  UltimatePortfolioApp
//
//  Created by Kris Siangchaew on 23/10/2563 BE.
//

import SwiftUI
import CoreSpotlight

struct ContentView: View {
    @SceneStorage("selectedView") var selectedView: String?
    @EnvironmentObject var dataController: DataController
    
    private let newProjectActivity = "com.krisdasiangchaew.UltimatePortfolioApp.newProject"

    var body: some View {
        TabView(selection: $selectedView) {
            HomeView(dataController: dataController)
                .tag(HomeView.tag)
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }

            ProjectsView(dataController: dataController, showClosedProjects: false)
                .tag(ProjectsView.openTag)
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Open")
                }

            ProjectsView(dataController: dataController, showClosedProjects: true)
                .tag(ProjectsView.closedTag)
                .tabItem {
                    Image(systemName: "checkmark")
                    Text("Closed")
                }

            AwardsView()
                .tag(AwardsView.tag)
                .tabItem {
                    Image(systemName: "rosette")
                    Text("Awards")
                }
        }
        .onContinueUserActivity(CSSearchableItemActionType, perform: moveToHome)
        .userActivity(newProjectActivity, { activity in
            activity.isEligibleForPrediction = true
            activity.title = "New Project"
        })
        .onAppear(perform: dataController.appLaunched)
        .onOpenURL(perform: openURL)
        .onContinueUserActivity(newProjectActivity, perform: createProject)
    }

    func moveToHome(_ input: Any) {
        selectedView = HomeView.tag
    }
    
    func openURL(_ url: URL) {
        selectedView = ProjectsView.openTag
        _ = dataController.addProject()
    }
    
    func createProject(_ userActivity: NSUserActivity) {
        selectedView = ProjectsView.openTag
        dataController.addProject()
    }
}

struct ContentView_Previews: PreviewProvider {
    static let dataController = DataController.preview
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, dataController.container.viewContext)
                .environmentObject(dataController)
    }
}
