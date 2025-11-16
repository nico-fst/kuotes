//
//  ContentView.swift
//  kuotes
//
//  Created by Nico Stern on 13.11.25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Kuotes", systemImage: "quote.bubble.fill") {
               KuotesView()
            }
            Tab("Folders", systemImage: "folder.fill") {
                FolderView()
            }
            Tab("Settings", systemImage: "gearshape.fill") {
               SettingsView()
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Folder.self, Kuote.self], inMemory: true)
}
