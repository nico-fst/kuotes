//
//  SearchView.swift
//  kuotes
//
//  Created by Nico Stern on 28.04.26.
//

import SwiftUI
import SwiftData

struct SearchView: View {
    @EnvironmentObject var bookVM: BookKuotesViewModel
    
    @State private var searchText: String = ""
    
    @Query(sort: \Kuote.datetime, order: .reverse) var kuotes: [Kuote]
    
    @Namespace private var noNamespace
    
    var searchedKuotes: [Kuote] {
        kuotes.filter { kuote in
            let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            if query.isEmpty { return true }

            return kuote.text.localizedCaseInsensitiveContains(query)
                || kuote.fileItem.displayName.localizedCaseInsensitiveContains(query)
            || String(kuote.pageno).localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(searchedKuotes, id: \.self) { kuote in
                    KuoteRow(kuote: kuote, selectedKuote: .constant(nil), kuoteAnimation: noNamespace, onSelect: {}, onChanged: {}, onDelete: {})
                    
                }
            }
            .listStyle(.plain)
            .background(.kBackground)
            .listRowBackground(Color.clear)
            .navigationTitle("Newest Quotes")
            .searchable(
                text: $searchText,
                placement: .automatic,
                prompt: "Search newest Kuotes"
            )
        }
    }
}
