//
//  KuotesView.swift
//  kuotes
//
//  Created by Nico Stern on 16.11.25.
//

import SwiftData
import SwiftUI

struct KuotesView: View {
    @Binding var pendingKuoteID: String?
    @AppStorage("selectedKuotesFolderPath") var selectedKuotesFolderPath:
        String = ""
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Kuote.pageno) private var kuotes: [Kuote]
    @State private var selectedKuote: Kuote? = nil
    @State private var vm: KuotesViewModel? = nil  // async mit modelContext befüllt
    @EnvironmentObject var filterVM: FilterHeaderViewModel  // in ContentView einmalig instanziiert
    @EnvironmentObject var navVM: NavigationViewModel // e.g. navVM.presentedBooks für NavigationStack

    var filteredKuotes: [Kuote] {
        kuotes.filter { kuote in
            (filterVM.selectedColorFilter.isEmpty
                || filterVM.selectedColorFilter.contains(kuote.color))
                && (filterVM.selectedDrawerFilter.isEmpty
                    || filterVM.selectedDrawerFilter.contains(kuote.drawer))
        }
    }

    var bookNames: [String] {
        // Array(Set()) makes unique
        Array(Set(filteredKuotes.map { $0.fileItem.displayName })).sorted()
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            NavigationStack(path: $navVM.presentedBooks) {
                List {
                    NavigationLink(value: "All Books") {
                        Text("All Books").bold()
                    }
                    ForEach(bookNames, id: \.self) { bookName in
                        NavigationLink(value: bookName) {
                            Text(bookName)
                        }
                    }
                }
                .navigationDestination(for: String.self) { bookName in
                    if bookName == "All Books" {
                        BookKuotesView(
                            bookName: "All Books",
                            kuotes: filteredKuotes,
                            selectedKuote: $selectedKuote
                        )
                    } else {
                        BookKuotesView(
                            bookName: bookName,
                            kuotes: filteredKuotes.filter {
                                $0.fileItem.displayName == bookName
                            },
                            selectedKuote: $selectedKuote
                        )
                    }
                }
                .task {  // weil @Environment bei Initializer oben noch nicht available wäre
                    if vm == nil {
                        vm = KuotesViewModel(modelContext: modelContext)
                    }
                }
                .refreshable { await vm?.reloadKuotes() }
                .navigationTitle("Kuotes")
                .navigationSubtitle("Fetched from \(selectedKuotesFolderPath)")
                .sheet(item: $selectedKuote) { kuote in
                    NavigationStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Spacer()

                            Text(kuote.chapter)
                                .font(.headline)
                                .italic()
                            Text(kuote.text)
                                .padding(8)
                                .background(
                                    kuote.color.swiftUIColor.opacity(0.3)
                                )
                                .cornerRadius(10)
                            Text(
                                verbatim:
                                    "\(kuote.drawer) on page \(kuote.pageno)"
                            )  // verbatim constructs non-localized string (localized deprecated)
                            .font(.subheadline)
                            .opacity(0.3)

                            Spacer()
                        }
                        .navigationTitle(kuote.fileItem.displayName)
                        .padding()
                    }
                    .presentationDetents([.medium, .large])
                }
            }
            .onChange(of: pendingKuoteID) { _, newValue in
                Task {
                    if let id = newValue {
                        if let kuote = vm?.getKuote(id: id) {
                            navVM.presentedBooks = [kuote.fileItem.displayName] // zugehörige Buchseite im NavStack öffnen
                            selectedKuote = kuote // Buch-Sheet öffnen
                            pendingKuoteID = nil
                        }
                    }
                }
            }

            FilterHeader()
                .background(.ultraThinMaterial)
                .cornerRadius(40)
                .padding()
                .padding(.horizontal, 15)
        }
    }
}

#Preview {
    KuotesView(pendingKuoteID: .constant(nil))
        .environmentObject(FilterHeaderViewModel())
}
