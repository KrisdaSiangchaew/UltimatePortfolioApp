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
        let predicate = NSPredicate(format: "completed = false")
        
        let fetchRequest = NSFetchRequest<Item>(entityName: "Item")
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.predicate = predicate
        
        items = FetchRequest(fetchRequest: fetchRequest)
    }
    
    var rows: [GridItem] = [
        GridItem(.fixed(100))
    ]
    
    @ViewBuilder
    func list(_ title: LocalizedStringKey, for items: FetchedResults<Item>.SubSequence) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            ForEach(items) { item in
                NavigationLink(destination: EditItemView(item: item)) {
                    HStack {
                        Circle()
                            .stroke(Color(item.project?.projectColor ?? "Light Blue"), lineWidth: 3)
                            .frame(width: 44, height: 44)
                            .padding()
                        VStack(alignment: .leading) {
                            Text(item.itemTitle)
                                .font(.title2)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            if !item.itemDetail.isEmpty {
                                Text(item.itemDetail)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .background(Color.secondarySystemGroupedBackground)
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.2), radius: 5)
                }
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Horizontal scrolling all projects
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHGrid(rows: rows, spacing: 16) {
                            ForEach(projects) { project in
                                VStack(alignment: .leading) {
                                    Text("\(project.projectItems.count) items")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(project.projectTitle)
                                        .font(.title2)
                                    ProgressView(value: project.completionAmount)
                                        .accentColor(Color(project.projectColor))
                                }
                                .padding()
                                .background(Color.secondarySystemGroupedBackground)
                                .cornerRadius(10)
                                .shadow(color: Color.black.opacity(0.2), radius: 5)
                            }
                        }
                        .padding([.horizontal, .top])
                        .fixedSize(horizontal: false, vertical: true)
                    }
                    // Up next (3 items)
                    VStack(alignment: .leading, spacing: 30) {
                        list("Up next", for: items.wrappedValue.prefix(3))
                        // More to explore items
                        list("More to explore", for: items.wrappedValue.dropFirst(3))
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Home")
            .background(Color.systemGroupedBackground.ignoresSafeArea())
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
