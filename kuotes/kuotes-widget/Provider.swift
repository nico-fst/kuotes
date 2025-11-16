//
//  Provider.swift
//  kuotes
//
//  Created by Nico Stern on 14.11.25.
//

import WidgetKit
import System
import SwiftData

struct SharedModelConfig {
    static var schema: Schema {
        Schema([Kuote.self, Folder.self])
    }
    static var config: ModelConfiguration {
        let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.de.nicostern.kuotes")!
            .appendingPathComponent("kuotes.sqlite")
        
        return ModelConfiguration(
            schema: schema,
            url: url
        )
    }
}

extension SharedModelConfig {
    static let sharedContainer: ModelContainer = {
        try! ModelContainer(
            for: schema,
            configurations: [config]
        )
    }()
}

struct Provider: TimelineProvider{
    @MainActor // wegen FetchDescriptor
    private func fetchKuotes() -> [Kuote]? {
        do {
            let container = SharedModelConfig.sharedContainer
            let descriptor = FetchDescriptor<Kuote>()
            let kuotes = try container.mainContext.fetch(descriptor)
            
            return kuotes
        } catch {
            print("Error fetching all Kuotes in Provder: ", error)
            return nil
        }
    }
    
    // dummy data, e.g. in gallery
    func placeholder(in context: Context) -> KuoteEntry {
        KuoteEntry(date: Date(), kuote: .templateKuote)
    }

    // completion-Aufruf asynchron => "entkommt" der f
    func getSnapshot(in context: Context, completion: @escaping (KuoteEntry) -> ()) {
        Task {
            let kuotes = await fetchKuotes() ?? []
            let randomKuote = kuotes.randomElement() ?? .templateKuote
            let entry = KuoteEntry(date: Date(), kuote: randomKuote)
            completion(entry) // Closure, die aufgerufen, sobald Entry erstellt
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [KuoteEntry] = []
        
        Task {
            let kuotes = await fetchKuotes() ?? []
            for kuote in kuotes {
                print("Kuotes: ", kuote.text)
            }
            
            // Generate a timeline consisting of X entries Y apart, starting from the current date.
            let currentDate = Date()
            for hourOffset in 0 ..< 11 {
                let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
                let entry = KuoteEntry(
                    date: entryDate,
                    kuote: kuotes.randomElement() ?? .templateKuote
                )
                entries.append(entry)
                print("Neuer Timeline Eintrag: ", entry.kuote.text)
            }
            
            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
        }
    }
}

