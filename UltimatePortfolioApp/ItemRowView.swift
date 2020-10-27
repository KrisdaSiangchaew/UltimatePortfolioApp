//
//  ItemRowView.swift
//  UltimatePortfolioApp
//
//  Created by Kris Siangchaew on 27/10/2563 BE.
//

import SwiftUI

struct ItemRowView: View {
    @ObservedObject var item: Item
    
    var body: some View {
        NavigationLink(item.itemTitle, destination: EditItemView(item: item))    }
}

struct ItemRowView_Previews: PreviewProvider {
    static var previews: some View {
        ItemRowView(item: Item.example)
    }
}
