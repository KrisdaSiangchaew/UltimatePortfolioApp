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

    @State private var showingSortOrder = false
    @State private var sortOrder = Item.SortOrder.optimized

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

    var projectList: some View {
        List {
            ForEach(projects.wrappedValue) { project in
                Section(header: ProjectHeaderView(project: project)) {
                    ForEach(project.projectItems(using: sortOrder)) { item in
                        ItemRowView(project: project, item: item)
                    }
                    .onDelete { indexSet in
                        delete(indexSet, from: project)
                    }

                    if showClosedProjects == false {
                        Button {
                            addItem(to: project)
                        } label: {
                            Label("Add New Item", systemImage: "plus")
                        }
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }

    var addProjectToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            if showClosedProjects == false {
                Button(action: addProject) {
                    if UIAccessibility.isVoiceOverRunning {
                        Text("Add Project")
                    } else {
                        Label("Add Project", systemImage: "plus")
                    }
                }
            }
        }
    }

    var sortToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                showingSortOrder.toggle()
            } label: {
                Label("Sort", systemImage: "arrow.up.arrow.down")
            }
        }
    }

    fileprivate func addItem(to project: Project) {
        withAnimation {
            let item = Item(context: moc)
            item.project = project
            item.creationDate = Date()
            dataController.save()
        }
    }

    fileprivate func delete(_ indexSet: IndexSet, from project: Project) {
        let allItems = project.projectItems(using: sortOrder)

        for index in indexSet {
            let item = allItems[index]
            dataController.delete(item)
        }
        dataController.save()
    }

    fileprivate func addProject() {
        withAnimation {
            let project = Project(context: moc)
            project.closed = false
            project.creationDate = Date()
            dataController.save()
        }
    }

    var body: some View {
        NavigationView {
            Group {
                if projects.wrappedValue.count == 0 {
                    Text("There's nothing here right now.")
                        .foregroundColor(.secondary)
                } else {
                    projectList
                }
            }
            .toolbar {
                addProjectToolbarItem
                sortToolbarItem
            }
            .navigationTitle(showClosedProjects ? "Closed Projects" : "Open Projects")
            .actionSheet(isPresented: $showingSortOrder) {
                ActionSheet(title: Text("Sort items"), message: nil, buttons: [
                    .default(Text("Optimized"), action: { sortOrder = .optimized}),
                    .default(Text("Creation Date"), action: { sortOrder = .creationDate}),
                    .default(Text("Title"), action: { sortOrder = .title})
                ])
            }

            SelectSomethingView()
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
