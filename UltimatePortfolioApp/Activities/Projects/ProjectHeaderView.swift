//
//  ProjectHeaderView.swift
//  UltimatePortfolioApp
//
//  Created by Kris Siangchaew on 30/10/2563 BE.
//

import SwiftUI

struct ProjectHeaderView: View {
    @ObservedObject var project: Project

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(project.projectTitle)

                ProgressView(value: project.completionAmount)
                    .accentColor(Color(project.projectColor))
            }

            Spacer()

            NavigationLink(destination: EditProjectView(project: project)) {
                    Image(systemName: "square.and.pencil")
                        .imageScale(.large)
                }
        }
        .accessibilityElement(children: .combine)
        .padding(.bottom, 10)
    }
}

struct ProjectHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectHeaderView(project: Project.example)
    }
}
