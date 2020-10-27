//
//  HomeView.swift
//  UltimatePortfolioApp
//
//  Created by Kris Siangchaew on 23/10/2563 BE.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var dataController: DataController
    
    static let tag: String? = "Home"
    
    var body: some View {
        NavigationView {
            VStack {
                Button("Add Data") {
                    dataController.deleteAll()
                    try? dataController.createSampleData()
                }
            }
            .navigationTitle("Home")
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static let dataController = DataController()
    static var previews: some View {
        HomeView()
    }
}
