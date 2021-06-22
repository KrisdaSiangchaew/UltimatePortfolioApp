//
//  HomeViewModel.swift
//  UltimatePortfolioApp
//
//  Created by Kris Siangchaew on 20/3/2564 BE.
//

import CoreData
import Foundation

extension HomeView {
    class ViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
        private let projectsController: NSFetchedResultsController<Project>
        private let itemsController: NSFetchedResultsController<Item>

        @Published var projects = [Project]()
        @Published var items = [Item]()
        @Published var selectedItem: Item?

        @Published var upNext = ArraySlice<Item>()
        @Published var moreToExplore = ArraySlice<Item>()

        var dataController: DataController

        init(dataController: DataController) {
            self.dataController = dataController

            let projectRequest: NSFetchRequest<Project> = Project.fetchRequest()
            projectRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Project.title, ascending: true)]
            projectRequest.predicate = NSPredicate(format: "closed = %d", false)

            projectsController = NSFetchedResultsController(
                fetchRequest: projectRequest,
                managedObjectContext: dataController.container.viewContext,
                sectionNameKeyPath: nil,
                cacheName: nil
            )

            let itemRequest = dataController.fetchRequestForTopItems(count: 10)

            itemsController = NSFetchedResultsController(
                fetchRequest: itemRequest,
                managedObjectContext: dataController.container.viewContext,
                sectionNameKeyPath: nil,
                cacheName: nil
            )

            super.init()

            projectsController.delegate = self
            itemsController.delegate = self

            do {
                try projectsController.performFetch()
                try itemsController.performFetch()
                projects = projectsController.fetchedObjects ?? []
                items = itemsController.fetchedObjects ?? []
                upNext = items.prefix(3)
                moreToExplore = items.dropFirst(3)
            } catch {
                print("Failed to fetch initial data")
            }
        }

        func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            if let newProjects = controller.fetchedObjects as? [Project] {
                projects = newProjects
            } else if let newItems = controller.fetchedObjects as? [Item] {
                items = newItems
                upNext = items.prefix(3)
                moreToExplore = items.dropFirst(3)
            }
        }

        func addSampleData() {
            dataController.deleteAll()
            try? dataController.createSampleData()
        }

        func selectItem(with identifier: String) {
            selectedItem = dataController.item(with: identifier)
        }
    }
}
