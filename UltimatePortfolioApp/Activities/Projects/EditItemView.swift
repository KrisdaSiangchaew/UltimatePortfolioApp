//
//  EditItemView.swift
//  UltimatePortfolioApp
//
//  Created by Kris Siangchaew on 27/10/2563 BE.
//

import SwiftUI

struct EditItemView: View {
    @EnvironmentObject var dataController: DataController

    let item: Item

    @State private var title: String
    @State private var detail: String
    @State private var priority: Int
    @State private var completed: Bool

    init(item: Item) {
        self.item = item

        _title = State(wrappedValue: item.itemTitle)
        _detail = State(wrappedValue: item.itemDetail)
        _priority = State(wrappedValue: Int(item.priority))
        _completed = State(wrappedValue: item.completed)
    }

    var body: some View {
        Form {
            Section(header: Text("Basic settings")) {
                TextField("Title", text: $title.onChange(update))
                TextField("Description", text: $detail.onChange(update))
            }

            Section(header: Text("Priority")) {
                Picker("Priority", selection: $priority.onChange(update)) {
                    Text("Low").tag(1)
                    Text("Medium").tag(2)
                    Text("High").tag(3)
                }
                .pickerStyle(SegmentedPickerStyle())
            }

            Section {
                Toggle("Mark Completed", isOn: $completed.onChange(update))
            }
        }
        .navigationTitle("Edit Item")
//        .onChange(of: title, perform: { _ in update() })
//        .onChange(of: detail, perform: { _ in update() })
//        .onChange(of: priority, perform: { _ in update() })
//        .onChange(of: completed, perform: { _ in update() })
        .onDisappear(perform: save)
    }

    func update() {
        item.project?.objectWillChange.send()
        item.title = title
        item.detail = detail
        item.priority = Int16(priority)
        item.completed = completed
    }

    func save() {
        dataController.update(item)
    }
}

struct EditItemView_Previews: PreviewProvider {
    static var previews: some View {
        EditItemView(item: Item.example)
    }
}
