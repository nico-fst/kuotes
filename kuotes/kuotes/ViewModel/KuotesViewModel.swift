//
//  KuotesViewModel.swift
//  kuotes
//
//  Created by Nico Stern on 16.11.25.
//

import Foundation
import SwiftData
import SwiftUI
import Combine

class KuotesViewModel: ObservableObject {
    private var modelContext: ModelContext
    @AppStorage("selectedKuotesFolderPath") var selectedKuotesFolderPath: String = ""
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func reloadKuotes() async {
        do {
            //  alte Kuotes löschen
            let oldKuotes = try modelContext.fetch(FetchDescriptor<Kuote>())
            for kuote in oldKuotes { modelContext.delete(kuote) }
            
            // neue Kuotes speichern
            let newKuotes: [Kuote] = try await FetchServices.shared.fetchKuotes(endpoint: selectedKuotesFolderPath)
            for kuote in newKuotes { modelContext.insert(kuote) }
            
            // speichern - optional, weil eig mit Auto-Save implizit
            try modelContext.save()
        } catch {
            print("Error replacing cached Kuotes with fetched ones: ", error)
        }
    }
    
    /// Retrieves a Kuote object by its string ID.
    /// - Parameter id: The string representation of the Kuote's UUID.
    /// - Returns: A Kuote object if found, otherwise nil.
    func getKuote(id: String) -> Kuote? {
        do {
            let kuotes = try self.modelContext.fetch(FetchDescriptor<Kuote>()) // weil nicht direkt Zugriff auf @Query
            if let uuid = UUID(uuidString: id) {
                if let match = kuotes.first(where: { $0.id == uuid }) {
                    return match
                }
            }
        } catch {
            return nil
        }
        return nil
    }
}
