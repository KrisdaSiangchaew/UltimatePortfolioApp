//
//  ProjectView.swift
//  UltimatePortfolioApp
//
//  Created by Kris Siangchaew on 23/10/2563 BE.
//

import SwiftUI

struct ProjectsView: View {
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var dataController: DataController
    
    let showClosedProjects: Bool
    let projects: FetchRequest<Project>
    
    static let openTag: String? = "Open"
    static let closedTag: String? = "Close"
    
    init(showClosedProjects: Bool) {
        self.showClosedProjects = showClosedProjects
        
        self.projects = FetchRequest<Project>(
            entity: Project.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Project.creationDate, ascending: false)],
            predicate: NSPredicate(format: "closed = %d", showClosedProjects))
        
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(projects.wrappedValue) { project in
                    Section(header: ProjectHeaderView(project: project)) {
                        ForEach(project.projectItems, content: ItemRowView.init)
                            .onDelete { indexSet in
                                let allItems = project.projectItems
                                
                                for index in indexSet {
                                    let item = allItems[index]
                                    dataController.delete(item)
                                }
                                dataController.save()
                            }
                        if showClosedProjects == false {
                            Button {
                                withAnimation {
                                    let item = Item(context: moc)
                                    item.project = project
                                    item.creationDate = Date()
                                    dataController.save()
                                }
                            } label: {
                                Label("Add New Item", systemImage: "plus")
                            }
                        }
                    }
                }
            }
            .toolbar {
                if showClosedProjects == false {
                    Button {
                        withAnimation {
                            let project = Project(context: moc)
                            project.closed = false
                            project.creationDate = Date()
                            dataController.save()
                        }
                    } label: {
                        Label("Add Project", systemImage: "plus")
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle(showClosedProjects ? "Closed Projects" : "Open Projects")
        }
    }
}

struct ProjectsView_Previews: PreviewProvider {
    static let dataController = DataController.preview
    static var previews: some View {
        ProjectsView(showClosedProjects: false)
            .environment(\.managedObjectContext, dataController.container.viewContext)
            .environmentObject(dataController)
    }
}
