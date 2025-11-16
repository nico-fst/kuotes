//
//  FolderViewModel.swift
//  kuotes
//
//  Created by Nico Stern on 16.11.25.
//

import Foundation
import SwiftData
import SwiftUI
import Combine

class FolderViewModel: ObservableObject {
    private var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func reloadFolders() async {
        do {
            // alte folder löschen
            let oldFolders = try modelContext.fetch(FetchDescriptor<Folder>())
            oldFolders.forEach { modelContext.delete($0) }
            
            // neue folder speichern
            let fetchedFolders = try await FetchServices.shared.fetchFolders(endpoint: "/")
            fetchedFolders.forEach { modelContext.insert($0) }
            
            // speichern - optional, weil eig mit Auto-Save implizit
            try modelContext.save()
        } catch {
            print("Error replacing cached folders with fetched ones: ", error)
        }
    }
}

