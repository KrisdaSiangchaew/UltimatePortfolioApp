//
//  AwardsView.swift
//  UltimatePortfolioApp
//
//  Created by Kris Siangchaew on 17/11/2563 BE.
//

import SwiftUI

struct AwardsView: View {
    static let tag: String? = "Awards"
    
    @EnvironmentObject var dataController: DataController
    @State private var selectedAward = Award.example
    @State private var showAwardDetails = false
    
    let columns: [GridItem] = [
        GridItem(.adaptive(minimum: 100, maximum: 100)),
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(Award.allAwards) { award in
                        Button {
                            selectedAward = award
                            showAwardDetails = true
                        } label: {
                            Image(systemName: award.image)
                                .resizable()
                                .scaleEffect()
                                .padding()
                                .frame(width: 100, height: 100)
                                .foregroundColor(dataController.hasEarned(award: award) ?
                                                    Color(award.color) : Color.secondary.opacity(0.5))
                        }
                        .accessibilityLabel(Text(dataController.hasEarned(award: award) ? "Unlocked: \(award.name)" : "Locked"))
                        .accessibility(hint: Text(award.description))
                    }
                }
                .navigationTitle("Awards")
            }
            .alert(isPresented: $showAwardDetails) {
                Alert(title: Text(dataController.hasEarned(award: selectedAward) ? "Unlocked" : "Locked"), message: Text(selectedAward.description), dismissButton: .default(Text("OK")))
            }
        }
    }
}

struct AwardsView_Previews: PreviewProvider {
    static var previews: some View {
        AwardsView()
    }
}
