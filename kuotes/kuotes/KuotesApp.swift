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
            ContentView()
        }
        // inject Container in Environment-Tree => alle Views haben Zugriff auf DB
        // ginge auch .modelContainer(for: [Folder.self]
        .modelContainer(sharedModelContainer)
    }
}
