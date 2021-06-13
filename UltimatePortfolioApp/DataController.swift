//
//  DataController.swift
//  UltimatePortfolioApp
//
//  Created by Kris Siangchaew on 23/10/2563 BE.
//

import CoreData
import CoreSpotlight
import UserNotifications

/// An environment singleton to manage our Core Data stack, including handling saving, counting fetch requests,
/// tracking awards, and dealing with sample data.
class DataController: ObservableObject {
    /// The lone CloudKit container used to store all our data.
    let container: NSPersistentCloudKitContainer
    
    // The UserDefaults suite where we are saving user data
    let defaults: UserDefaults
    
    // Loads and saves whether our premium unlock has been purchased
    var fullVersionUnlocked: Bool {
        get {
            defaults.bool(forKey: "fullVersionUnlocked")
        }
        
        set {
            defaults.set(newValue, forKey: "fullVersionUnlocked")
        }
    }

    static var preview: DataController = {
        let controller = DataController(inMemory: true)

        do {
            try controller.createSampleData()
        } catch {
            fatalError("Fatal error creating preview: \(error.localizedDescription)")
        }
        return controller
    }()

    // Static property that will locate the Main.momd in our bundle and load it into an
    // NSManagedObjectModel instance. This prevents "Multiple NSEntityDescriptions
    // claim the NSManagedObject subclass..." error warning because new managedObjectModel
    // is loaded every time. (See the init for DataController.)
    static let model: NSManagedObjectModel = {
        guard let url = Bundle.main.url(forResource: "Main", withExtension: "momd") else {
            fatalError("Failed to locate model file.")
        }

        guard let managedObjectModel = NSManagedObjectModel(contentsOf: url) else {
            fatalError("Failed to load model file.")
        }

        return managedObjectModel
    }()

    /// Initializes a data controller either in memory (for temporary use such as testing and previewing.
    ///  or on permanent storage (for use in regular app runs.)
    ///
    /// Defaults to permanent storage.
    /// - Parameter inMemory: Where to store this data in temporary memory or not.
    /// - Parameter defaults: The UserDefaults suite where user data should be stored
    init(inMemory: Bool = false, defaults: UserDefaults = .standard) {
        self.defaults = defaults
        
        container = NSPersistentCloudKitContainer(name: "Main", managedObjectModel: Self.model)

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { (_, error) in
            if let error = error {
                fatalError("Fatal error loading store: \(error.localizedDescription)")
            }

            #if DEBUG
            if CommandLine.arguments.contains("enable-testing") {
                self.deleteAll()
            }
            #endif
        }
    }

    /// Creates example projects and items to make manual testing easier.
    /// - Throws: An NSError sent from calling save() on the NSManagedObjectContext.
    func createSampleData() throws {
        let viewContext = container.viewContext

        (1...5).forEach { projectCounter in
            let project = Project(context: viewContext)
            project.title = "Project \(projectCounter)"
            project.creationDate = Date()
            project.items = []
            project.closed = Bool.random()
            (1...10).forEach { itemCounter in
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

    /// Saves our Core Data context iff there are changes. This silently ignores
    /// any errors caused by saving, but this should be fine because our
    /// attributes are optional.
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
    
    // MARK: - CoreSpotlight

    func update(_ item: Item) {
        let itemID = item.objectID.uriRepresentation().absoluteString
        let projectID = item.project?.objectID.uriRepresentation().absoluteString

        let attributeSet = CSSearchableItemAttributeSet(contentType: .text)
        attributeSet.title = item.title
        attributeSet.contentDescription = item.detail

        let searchableItem = CSSearchableItem(
            uniqueIdentifier: itemID,
            domainIdentifier: projectID,
            attributeSet: attributeSet)

        CSSearchableIndex.default().indexSearchableItems([searchableItem])

        save()
    }

    func item(with uniqueIdentifier: String) -> Item? {
        guard let url = URL(string: uniqueIdentifier) else {
            return nil
        }

        guard let id = container.persistentStoreCoordinator.managedObjectID(forURIRepresentation: url) else {
            return nil
        }

        return try? container.viewContext.existingObject(with: id) as? Item
    }
    
    // MARK: - UserNotifications
    
    func addReminders(for project: Project, completion: @escaping (Bool) -> Void) {
        // 1. Check our authorization status for local notification
        // 2. If status is not determined - i.e. user made no choice - do something
        // 3. If status is authorized, we call placeReminders immediately
        // 4. If we're in any other authorization state, we'll consider it a failure
        let center = UNUserNotificationCenter.current()
        
        center.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                self.requestNotification { success in
                    if success {
                        self.placeReminders(for: project, completion: completion)
                    } else {
                        DispatchQueue.main.async {
                            completion(false)
                        }
                    }
                }
            case .authorized:
                self.placeReminders(for: project, completion: completion)
            default:
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    }
    
    func removeReminders(for project: Project) {
        let id = project.objectID.uriRepresentation().absoluteString
        
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [id])
    }
    
    private func requestNotification(completion: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
            completion(granted)
        }
    }
    
    private func placeReminders(for project: Project, completion: @escaping (Bool) -> Void) {
        // Deciding the content of the notification
        let content = UNMutableNotificationContent()
        content.sound = .default
        content.title = project.projectTitle
        if let projectDetail = project.detail {
            content.subtitle = projectDetail
        }
        
        // Telling iOS when the notification should be shown
        let components = Calendar.current.dateComponents([.hour, .minute], from: project.reminderTime ?? Date())
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        // Wrapping above two pieces of information along with a unique identifier
        let id = project.objectID.uriRepresentation().absoluteString
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
    
        // Sending it off to iOS to be shown while handling the response carefully
        UNUserNotificationCenter.current().add(request) { error in
            DispatchQueue.main.async {
                if error == nil {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    }
}
