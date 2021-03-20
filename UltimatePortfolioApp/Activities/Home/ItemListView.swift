//
//  ItemListView.swift
//  UltimatePortfolioApp
//
//  Created by Kris Siangchaew on 19/12/2563 BE.
//

import SwiftUI

struct ItemListView: View {
    let title: LocalizedStringKey
    let items: ArraySlice<Item>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            ForEach(items) { item in
                NavigationLink(destination: EditItemView(item: item)) {
                    HStack {
                        Circle()
                            .stroke(Color(item.project?.projectColor ?? "Light Blue"), lineWidth: 3)
                            .frame(width: 44, height: 44)
                            .padding()
                        VStack(alignment: .leading) {
                            Text(item.itemTitle)
                                .font(.title2)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            if !item.itemDetail.isEmpty {
                                Text(item.itemDetail)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .background(Color.secondarySystemGroupedBackground)
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.2), radius: 5)
                }
            }
        }
    }
}

// struct ItemListView_Previews: PreviewProvider {
//    static var previews: some View {
//        ItemListView()
//    }
// }
