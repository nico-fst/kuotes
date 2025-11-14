//
//  Provider.swift
//  kuotes
//
//  Created by Nico Stern on 14.11.25.
//

import WidgetKit
import System

struct Provider: TimelineProvider{
    // dummy data, e.g. in gallery
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), kuote: Kuote.templateKuote)
    }

    // completion-Aufruf asynchron => "entkommt" der f
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), kuote: Kuote.templateKuote)
        completion(entry) // Closure, die aufgerufen, sobald Entry erstellt
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, kuote: Kuote.templateKuote)
            entries.append(entry)
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}
