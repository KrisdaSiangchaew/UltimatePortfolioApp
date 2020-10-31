//
//  EditProjectView.swift
//  UltimatePortfolioApp
//
//  Created by Kris Siangchaew on 31/10/2563 BE.
//

import SwiftUI

struct EditProjectView: View {
    let project: Project
    @EnvironmentObject var dataController: DataController
    @Environment(\.presentationMode) var presentationMode
    
    @State private var showDeleteConfirm = false
    
    @State private var title: String
    @State private var detail: String
    @State private var color: String
    @State private var closed: Bool
    
    init(project: Project) {
        self.project = project
        
        _title = State(wrappedValue: project.projectTitle)
        _detail = State(wrappedValue: project.projectDetail)
        _color = State(wrappedValue: project.projectColor)
        _closed = State(wrappedValue: project.closed)
    }
    
    let colorColumns = GridItem(.adaptive(minimum: 44))
    
    var body: some View {
        Form {
            Section(header: Text("Basic settings")) {
                TextField("Title", text: $title.onChange(update))
                TextField("Description", text: $detail.onChange(update))
            }
            
            Section(header: Text("Custom project color")) {
                LazyVGrid(columns: [colorColumns]) {
                    ForEach(Project.colors, id: \.self) { item in
                        ZStack {
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
                            update()
                        }
                    }
                }
                .padding(.vertical)
            }
            
            Section(footer: Text("")) {
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
        .onDisappear(perform: dataController.save)
        .alert(isPresented: $showDeleteConfirm, content: {
            Alert(title: Text("Delete project?"),
                  message: Text("Are you sure you want to this project? It will also delete all items it contains."),
                  primaryButton: .default(Text("Delete"), action: delete),
                  secondaryButton: .cancel())
        })
    }
    
    func update() {
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
        EditProjectView(project: Project.example)
    }
}
