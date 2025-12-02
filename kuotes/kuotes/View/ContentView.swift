//
//  ContentView.swift
//  kuotes
//
//  Created by Nico Stern on 13.11.25.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @Binding var pendingQuoteID: String?  // to be viewed when pressing widget

    var body: some View {
        TabView {
            Tab("Kuotes", systemImage: "quote.bubble.fill") {
                KuotesView(pendingKuoteID: $pendingQuoteID)
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
    ContentView(pendingQuoteID: .constant(nil))
        .modelContainer(for: [Folder.self, Kuote.self], inMemory: true)
}
