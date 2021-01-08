//
//  EditProjectView.swift
//  UltimatePortfolioApp
//
//  Created by Kris Siangchaew on 31/10/2563 BE.
//

import SwiftUI

struct EditProjectView: View {
    @EnvironmentObject var dataController: DataController
    @Environment(\.presentationMode) var presentationMode

    let project: Project

    @State private var title: String
    @State private var detail: String
    @State private var color: String
    @State private var closed: Bool

    @State private var showDeleteConfirm = false

    init(project: Project) {
        self.project = project

        _title = State(wrappedValue: project.projectTitle)
        _detail = State(wrappedValue: project.projectDetail)
        _color = State(wrappedValue: project.projectColor)
        _closed = State(wrappedValue: project.closed)
    }

    let colorColumns = GridItem(.adaptive(minimum: 44))

    fileprivate func colorButton(_ item: String) -> some View {
        return ZStack {
            Color(item)
                .aspectRatio(1, contentMode: .fit)
                .cornerRadius(6)

            if color == item {
                Image(systemName: "checkmark.circle")
                    .foregroundColor(.white)
                    .font(.largeTitle)
            }
        }
        .onTapGesture {
            color = item
            // update()
        }
        .accessibilityElement(children: .ignore)
        .accessibilityAddTraits(item == color ? [.isButton, .isSelected] : .isButton)
        .accessibilityLabel(LocalizedStringKey(item))
    }

    var body: some View {
        Form {
            Section(header: Text("Basic settings")) {
                TextField("Title", text: $title) // .onChange(update))
                TextField("Description", text: $detail) // .onChange(update))
            }

            Section(header: Text("Custom project color")) {
                LazyVGrid(columns: [colorColumns]) {
                    ForEach(Project.colors, id: \.self, content: colorButton)
                }
                .padding(.vertical)
            }

            // swiftlint:disable:next line_length
            Section(footer: Text("Close this project will move this project to Closed tab. Delete the project will delete the project from memory.")) {
                Button(project.closed ? "Reopen this project" : "Close this project") {
                    project.closed.toggle()
                    update()
                }
                Button("Delete this project") {
                    showDeleteConfirm.toggle()
                }
                .accentColor(.red)
            }
        }
        .navigationTitle("Edit Project")
        .onDisappear(perform: update)
        .alert(isPresented: $showDeleteConfirm, content: {
            Alert(title: Text("Delete project?"),
                  // swiftlint:disable:next line_length
                  message: Text("Are you sure you want to delete this project? It will also delete all items it contains."),
                  primaryButton: .default(Text("Delete"), action: delete),
                  secondaryButton: .cancel())
        })
    }

    // Specifics: In iOS 14.3 calling update() here will cause the view to immediately switch back
    // to the parent view to get updated.
    // Solution: We do all the updaets thru State properties and only call update() from .onDisapper(perform:).
    // Side effect: The sideeffect when we moved back to the parent view, we will see the property being updated.
    // Reference: See the EditItemView where we update our State properties and thru Binding call update()
    // and it doesn't pop back to parent view using Binding directly to call update().
    func update() {
        dataController.save()
        project.title = title
        project.detail = detail
        project.color = color
    }

    func delete() {
        dataController.delete(project)
        presentationMode.wrappedValue.dismiss()
    }
}

struct EditProjectView_Previews: PreviewProvider {
    static var previews: some View {
        EditProjectView(project: Project.example)    }
}
