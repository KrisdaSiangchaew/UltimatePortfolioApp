//
//  AwardsView.swift
//  UltimatePortfolioApp
//
//  Created by Kris Siangchaew on 17/11/2563 BE.
//

import SwiftUI

struct AwardsView: View {
    static let tag: String? = "Awards"
    
    let columns: [GridItem] = [
        GridItem(.adaptive(minimum: 100, maximum: 100)),
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(Award.allAwards) { award in
                        Button {
                            
                        } label: {
                            Image(systemName: award.image)
                                .resizable()
                                .scaleEffect()
                                .padding()
                                .frame(width: 100, height: 100)
                                .foregroundColor(Color.secondary.opacity(0.5))
                        }
                    }
                }
                .navigationTitle("Awards")
            }
        }
    }
}

struct AwardsView_Previews: PreviewProvider {
    static var previews: some View {
        AwardsView()
    }
}
