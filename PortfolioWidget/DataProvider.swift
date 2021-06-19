//
//  DataProvider.swift
//  PortfolioWidgetExtension
//
//  Created by Krisda on 19/6/2564 BE.
//

import WidgetKit
import SwiftUI
import Intents

struct SimpleEntry: TimelineEntry {
    let date: Date
    let items: [Item]
}

struct Provider: TimelineProvider {
    typealias Entry = SimpleEntry

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), items: [Item.example])
    }

    func loadItems() -> [Item] {
        let dataController = DataController()
        let itemRequest = dataController.fetchRequestForTopItems(count: 5)
        return dataController.results(for: itemRequest)
    }

    func getSnapshot(
        in context: Context,
        completion: @escaping (SimpleEntry) -> Void) {

        let entry = SimpleEntry(date: Date(), items: loadItems())
        completion(entry)
    }

    func getTimeline(
        in context: Context,
        completion: @escaping (Timeline<Entry>) -> Void) {

        let entry = SimpleEntry(date: Date(), items: loadItems())
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
}
