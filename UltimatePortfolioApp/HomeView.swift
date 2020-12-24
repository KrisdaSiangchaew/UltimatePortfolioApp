//
//  HomeView.swift
//  UltimatePortfolioApp
//
//  Created by Kris Siangchaew on 23/10/2563 BE.
//

import SwiftUI
import CoreData

struct HomeView: View {
    @EnvironmentObject var dataController: DataController
    
    @FetchRequest<Project>(
        entity: Project.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Project.title, ascending: true)
        ],
        predicate: NSPredicate(format: "closed = false"))
    var projects: FetchedResults<Project>
    
    let items: FetchRequest<Item>
    
    static let tag: String? = "Home"

    init() {
        let sortDescriptors = [NSSortDescriptor(keyPath: \Item.priority, ascending: false)]
        let completedPredicate = NSPredicate(format: "completed = false")
        let openPredicate = NSPredicate(format: "project.closed = false")
        let compoundPredicate = NSCompoundPredicate(type: .and, subpredicates: [completedPredicate, openPredicate])
        
        let fetchRequest = NSFetchRequest<Item>(entityName: "Item")
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.predicate = compoundPredicate
        
        items = FetchRequest(fetchRequest: fetchRequest)
    }
    
    var rows: [GridItem] = [
        GridItem(.fixed(100))
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Horizontal scrolling all projects
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHGrid(rows: rows, spacing: 16) {
                            ForEach(projects) { project in
                                ProjectSummaryView(project: project)
                            }
                        }
                        .padding([.horizontal, .top])
                        .fixedSize(horizontal: false, vertical: true)
                    }
                    VStack(alignment: .leading, spacing: 30) {
                        ItemListView(title: "Up next", items: items.wrappedValue.prefix(3))
                        ItemListView(title: "More to explore", items: items.wrappedValue.dropFirst(3))
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Home")
            .background(Color.systemGroupedBackground.ignoresSafeArea())
            .toolbar {
                Button("Add Data") {
                    dataController.deleteAll()
                    try? dataController.createSampleData()
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static let dataController = DataController.preview
    
    static var previews: some View {
        HomeView()
            .environmentObject(dataController)
    }
}
