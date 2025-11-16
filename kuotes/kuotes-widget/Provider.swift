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

struct Provider: AppIntentTimelineProvider{
    @MainActor // wegen FetchDescriptor
    private func fetchKuotes(colorFilter: [ColorType]?, drawerFilter: [DrawerType]?) -> [Kuote]? {
        do {
            let container = SharedModelConfig.sharedContainer
            let descriptor = FetchDescriptor<Kuote>()
            let allKuotes = try container.mainContext.fetch(descriptor)
            
            // filter using colorFilter, drawerFilter
            var filteredKuotes = allKuotes
            if let colorFilter = colorFilter, !colorFilter.isEmpty { // wenn != nil Wert entpackt und unter selbem Namen colorFilter verfügbar gemacht
                filteredKuotes = filteredKuotes.filter { colorFilter.contains($0.color) }
            }
            if let drawerFilter = drawerFilter, !drawerFilter.isEmpty {
                filteredKuotes = filteredKuotes.filter { drawerFilter.contains($0.drawer) }
            }
            return filteredKuotes
        } catch {
            print("Error fetching all Kuotes in Provder: ", error)
            return nil
        }
    }
    
    // dummy data, e.g. in gallery
    func placeholder(in context: Context) -> KuoteEntry {
        KuoteEntry(date: Date(),
                   kuote: .templateShort,
                   configuration: ConfigurationAppIntent())
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> KuoteEntry {
        let kuotes = await fetchKuotes(colorFilter: configuration.colorFilter, drawerFilter: configuration.drawerFilter) ?? []
        let randomKuote = kuotes.randomElement() ?? .templateShort
        return KuoteEntry(date: Date(),
                          kuote: randomKuote,
                          configuration: configuration)
        // kein completion(), weil async
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<KuoteEntry> {
        var entries: [KuoteEntry] = []
        let kuotes = await fetchKuotes(colorFilter: configuration.colorFilter, drawerFilter: configuration.drawerFilter) ?? []
        
        // Generate a timeline consisting of X entries Y apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 11 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = KuoteEntry(
                date: entryDate,
                kuote: kuotes.randomElement() ?? .templateShort,
                configuration: configuration
            )
            entries.append(entry)
        }
        
        return Timeline(entries: entries, policy: .atEnd)
    }
}

