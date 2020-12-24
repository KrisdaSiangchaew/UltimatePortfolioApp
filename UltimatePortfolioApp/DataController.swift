//
//  DataController.swift
//  UltimatePortfolioApp
//
//  Created by Kris Siangchaew on 23/10/2563 BE.
//

import CoreData
import SwiftUI

class DataController: ObservableObject {
    let container: NSPersistentCloudKitContainer

    static var preview: DataController = {
        let controller = DataController(inMemory: true)

        do {
            try controller.createSampleData()
        } catch {
            fatalError("Fatal error creating preview: \(error.localizedDescription)")
        }
        return controller
    }()

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Main")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { (_, error) in
            if let error = error {
                fatalError("Fatal error loading store: \(error.localizedDescription)")
            }
        }
    }

    func createSampleData() throws {
        let viewContext = container.viewContext

        (1...5).forEach { projectCounter in
            let project = Project(context: viewContext)
            project.title = "Project \(projectCounter)"
            project.creationDate = Date()
            project.items = []
            project.closed = Bool.random()
            (1...5).forEach { itemCounter in
                let item = Item(context: viewContext)
                item.title = "Item \(itemCounter)"
                item.creationDate = Date()
                item.priority = Int16.random(in: 1...3)
                item.project = project
                item.completed = Bool.random()
            }
        }

        try viewContext.save()
    }

    func deleteAll() {
        let fetchRequest1: NSFetchRequest<NSFetchRequestResult> = Item.fetchRequest()
        let batchDeleteFetchRequest1 = NSBatchDeleteRequest(fetchRequest: fetchRequest1)
        _ = try? container.viewContext.execute(batchDeleteFetchRequest1)

        let fetchRequest2: NSFetchRequest<NSFetchRequestResult> = Project.fetchRequest()
        let batchDeleteFetchRequest2 = NSBatchDeleteRequest(fetchRequest: fetchRequest2)
        _ = try? container.viewContext.execute(batchDeleteFetchRequest2)
    }

    func save() {
        if container.viewContext.hasChanges {
            try? container.viewContext.save()
        }
    }

    func delete(_ object: NSManagedObject) {
        container.viewContext.delete(object)
    }

    func count<T>(for fetchRequest: NSFetchRequest<T>) -> Int {
        (try? container.viewContext.count(for: fetchRequest)) ?? 0
    }

    func hasEarned(award: Award) -> Bool {
        switch award.criterion {
        case "items":
            let fetchRequest: NSFetchRequest<Item> = NSFetchRequest(entityName: "Item")
            let awardCount = count(for: fetchRequest)
            return awardCount >= award.value

        case "complete":
            let fetchRequest: NSFetchRequest<Item> = NSFetchRequest(entityName: "Item")
            fetchRequest.predicate = NSPredicate(format: "completed = true")
            let awardCount = count(for: fetchRequest)
            return awardCount >= award.value

        default:
            // fatalError("Unknown award criterion \(award.criterion).")
            return false
        }
    }
}
