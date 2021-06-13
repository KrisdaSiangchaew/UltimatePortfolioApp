//
//  EditProjectView.swift
//  UltimatePortfolioApp
//
//  Created by Kris Siangchaew on 31/10/2563 BE.
//

import SwiftUI
import CoreHaptics

struct EditProjectView: View {
    @EnvironmentObject var dataController: DataController
    @Environment(\.presentationMode) var presentationMode

    @ObservedObject var project: Project

    @State private var title: String
    @State private var detail: String
    @State private var color: String
    @State private var closed: Bool

    @State private var showDeleteConfirm = false

    @State private var engine = try? CHHapticEngine()
    
    @State private var remindMe: Bool
    @State private var reminderTime: Date
    
    @State private var showNotificationsError = false

    init(project: Project) {
        self.project = project

        _title = State(wrappedValue: project.projectTitle)
        _detail = State(wrappedValue: project.projectDetail)
        _color = State(wrappedValue: project.projectColor)
        _closed = State(wrappedValue: project.closed)
        
        if let projectReminderTime = project.reminderTime {
            _reminderTime = State(wrappedValue: projectReminderTime)
            _remindMe = State(wrappedValue: true)
        } else {
            _reminderTime = State(wrappedValue: Date())
            _remindMe = State(wrappedValue: false)
        }
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
            
            Section(header: Text("Project reminders")) {
                Toggle("Show reminders", isOn: $remindMe.animation().onChange(update))
                
                if remindMe {
                    DatePicker(
                        "Reminder time",
                        selection: $reminderTime,
                        displayedComponents: .hourAndMinute)
                }
            }

            // swiftlint:disable:next line_length
            Section(footer: Text("Close this project will move this project to Closed tab. Delete the project will delete the project from memory.")) {
                Button(project.closed ? "Reopen this project" : "Close this project", action: toggleClosed)

                Button("Delete this project") {
                    showDeleteConfirm.toggle()
                }
                .accentColor(.red)
            }
            .alert(isPresented: $showDeleteConfirm) {
                Alert(
                    title: Text("Delete project?"),
                    // swiftlint:disable:next line_length
                    message: Text("Are you sure you want to delete this project? It will also delete all items it contains."),
                    primaryButton: .default(Text("Delete"), action: delete),
                    secondaryButton: .cancel())
                }
        }
        .navigationTitle("Edit Project")
        .onDisappear(perform: update)
        .alert(isPresented: $showNotificationsError) {
            Alert(
                title: Text("Oops!"),
                message: Text("There was a problem. Please check you have notifications enabled."),
                primaryButton: .default(Text("Check setting"), action: showAppSettings),
                secondaryButton: .cancel())
            }
    }

    // Specifics: In iOS 14.3 calling update() here will cause the view to immediately switch back
    // to the parent view to get updated.
    // Solution: We do all the updates thru State properties and only call update() from .onDisappear(perform:).
    // Side effect: The side-effect when we moved back to the parent view, we will see the property being updated.
    // Reference: See the EditItemView where we update our State properties and thru Binding call update()
    // and it doesn't pop back to parent view using Binding directly to call update().
    func update() {
        dataController.save()
        project.title = title
        project.detail = detail
        project.color = color
        
        if remindMe {
            project.reminderTime = reminderTime
            
            dataController.addReminders(for: project) { success in
                if success == false {
                    project.reminderTime = nil
                    remindMe = false
                    showNotificationsError = true
                }
            }
        } else {
            project.reminderTime = nil
            dataController.removeReminders(for: project)
        }
    }

    func delete() {
        dataController.delete(project)
        presentationMode.wrappedValue.dismiss()
    }

    func toggleClosed() {
        project.closed.toggle()

        if project.closed {
            do {
                try engine?.start()

                let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0)
                let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
                let start = CHHapticParameterCurve.ControlPoint(relativeTime: 0, value: 1)
                let end = CHHapticParameterCurve.ControlPoint(relativeTime: 1, value: 0)

                let parameter = CHHapticParameterCurve(
                    parameterID: .hapticIntensityControl,
                    controlPoints: [start, end],
                    relativeTime: 0
                )

                let event1 = CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [intensity, sharpness],
                    relativeTime: 0
                )

                let event2 = CHHapticEvent(
                    eventType: .hapticContinuous,
                    parameters: [sharpness, intensity],
                    relativeTime: 0.125,
                    duration: 1
                )

                let pattern = try CHHapticPattern(events: [event1, event2], parameterCurves: [parameter])

                let player = try engine?.makePlayer(with: pattern)
                try player?.start(atTime: 0)

            } catch {
                // playing haptics didn't work, but that's okay
                print(error.localizedDescription)
            }
        }
    }
    
    func showAppSettings() {
        guard let settingURL = URL(string: UIApplication.openSettingsURLString) else { return }
        
        if UIApplication.shared.canOpenURL(settingURL) {
            UIApplication.shared.open(settingURL)
        }
    }
}

struct EditProjectView_Previews: PreviewProvider {
    static var previews: some View {
        EditProjectView(project: Project.example)    }
}
