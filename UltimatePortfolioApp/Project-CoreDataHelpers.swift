//
//  Project-CoreDataHelpers.swift
//  UltimatePortfolioApp
//
//  Created by Kris Siangchaew on 26/10/2563 BE.
//

import SwiftUI

extension Project {
    var projectTitle: String {
        title ?? NSLocalizedString("New Project", comment: "Create a new project")
    }
    
    var projectDetail: String {
        detail ?? ""
    }
    
    var projectColor: String {
        color ?? "Light Blue"
    }
    
    static var example: Project {
        let controller = DataController(inMemory: true)
        let viewContext = controller.container.viewContext
        
        let project = Project(context: viewContext)
        project.title = "Example Project"
        project.detail = "This is an example project"
        project.closed = true
        project.creationDate = Date()
        
        return project
    }
    
    var projectItems: [Item] {
        items?.allObjects as? [Item] ?? []
    }
    
    func projectItems(using sortOrder: Item.SortOrder) -> [Item] {
        switch sortOrder {
        case .creationDate:
            return projectItems.sorted { $0.itemCreationDate < $1.itemCreationDate }
        case .title:
            return projectItems.sorted { $0.itemTitle < $1.itemTitle }
        case .optimized:
            return projectItemsDefaultSorted
        }
    }
    
    var projectItemsDefaultSorted: [Item] {
        return projectItems.sorted {
            if $0.completed == false {
                if $1.completed == true {
                    return true
                }
            } else if $0.completed == true {
                if $1.completed == false {
                    return false
                }
            }
            
            if $0.priority > $1.priority {
                return true
            } else if $0.priority < $1.priority {
                return false
            }
            
            return $0.itemCreationDate < $1.itemCreationDate
        }
    }
    
    var completionAmount: Double {
        let originalItems = items?.allObjects as? [Item] ?? []
        guard originalItems.isEmpty == false else { return 0 }
        
        let completedItems = originalItems.filter(\.completed)
        
        return Double(completedItems.count) / Double(originalItems.count)
    }
    
    var label: LocalizedStringKey {
        return "\(projectTitle), \(projectItems.count) items, \(completionAmount * 100, specifier: "%g")% complete."
    }
    
    static let colors = [
        "Dark Blue", "Dark Gray", "Gold", "Gray", "Green", "Light Blue", "Midnight", "Orange", "Pink", "Purple", "Red", "Teal"
    ]
}
