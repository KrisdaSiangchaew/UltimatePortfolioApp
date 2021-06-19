//
//  PortfolioWidget.swift
//  PortfolioWidget
//
//  Created by Krisda on 13/6/2564 BE.
//

import WidgetKit
import SwiftUI
import Intents

@main
struct PortfolioWidgets: WidgetBundle {
    var body: some Widget {
        SimplePortfolioWidget()
        ComplexPortfolioWidget()
    }
}

struct PortfolioWidget_Previews: PreviewProvider {
    static var previews: some View {
        PortfolioWidgetEntryView(entry: SimpleEntry(date: Date(), items: [Item.example]))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
