//
//  BookKuotesViewModel.swift
//  kuotes
//
//  Created by Nico Stern on 27.04.26.
//

import Combine
import Foundation

enum SortOrder: String, CaseIterable, Identifiable {
    case ascending = "Ascending"
    case descending = "Descending"

    var id: String { rawValue }
}

enum SortCriterium: String, CaseIterable, Identifiable {
    case page = "Page"
    case date = "Creation Date"

    var id: String { rawValue }
}

class BookKuotesViewModel: ObservableObject {
    @Published var sortOrder: SortOrder = .ascending
    @Published var sortCriterium: SortCriterium = .page
    
    @Published var didDeleteKuote: Bool = false
    @Published var didChangeSelectedKuote: Bool = false
    @Published var deleteError: String? = nil
    
    @Published var showFullSelectedKuote: Bool = false
    @Published var showFloatingEffect: Bool = false
    @Published var closingSelectedKuoteID: UUID? = nil
    
    func sortedKuotes(_ kuotes: [Kuote]) -> [Kuote] {
        switch sortOrder {
        case .ascending:
            switch sortCriterium {
            case .page:
                return kuotes.sorted { $0.pageno < $1.pageno }
            case .date:
                return kuotes.sorted { $0.datetime < $1.datetime }
            }
        case .descending:
            switch sortCriterium {
            case .page:
                return kuotes.sorted { $0.pageno > $1.pageno }
            case .date:
                return kuotes.sorted { $0.datetime > $1.datetime }
            }
        }
    }

    func isRowHidden(kuoteID: UUID, selectedKuoteID: UUID?) -> Bool {
        let isSelectedKuote = selectedKuoteID == kuoteID
        let isClosingSelectedKuote = closingSelectedKuoteID == kuoteID

        return isSelectedKuote && !isClosingSelectedKuote
    }

    func prepareForSelection() {
        showFloatingEffect = false
        showFullSelectedKuote = false
        closingSelectedKuoteID = nil
    }

    @MainActor
    func deleteKuote(_ kuote: Kuote) async {
        do {
            let found = try await FetchServices.shared.deleteHighlight(for: kuote)
            if !found {
                deleteError = "Kuote to be deleted could not be found"
            } else {
                didDeleteKuote = true
            }
        } catch {
            deleteError = error.localizedDescription
        }
    }
}
