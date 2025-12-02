//
//  kuotesApp.swift
//  kuotes
//
//  Created by Nico Stern on 13.11.25.
//

import SwiftUI
import SwiftData

@main
struct kuotesApp: App {
    @State private var pendingQuoteID: String? = nil
    
    // @Published vars in ObservableObject...
    // hier als @StateObject instanziieren und als .environmentObject injizieren...
    // ...dann überall selbe Instanz in Kindern als @EnvironmentObject aufrufbar
    @StateObject private var filterVM = FilterHeaderViewModel()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([Kuote.self, Folder.self])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            // AppGroup auswählen, auf die auch Widgets Zugriff haben
            url: FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.de.nicostern.kuotes")!
                .appendingPathComponent("kuotes.sqlite")
        )
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            // .modelContainer: inject Container in Environment-Tree => alle Views haben Zugriff auf DB
            // ginge auch .modelContainer(for: [Folder.self]
            ContentView(pendingQuoteID: $pendingQuoteID)
                .environmentObject(filterVM)
                .modelContainer(sharedModelContainer)
                .onOpenURL { url in
                    if url.scheme == "kuotes",
                       url.host == "kuote",
                       url.pathComponents.count > 1 {
                        let quoteID = url.pathComponents[1]
                        pendingQuoteID = quoteID
                    }
                }
        }
    }
}
