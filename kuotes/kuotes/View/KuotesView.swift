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
    @AppStorage("namingConventionOrder") private var namingConventionOrderRaw: String = NamingConventionOrder.titleFirst.rawValue
    @AppStorage("namingConventionSeparator") private var namingConventionSeparator: String = "-"
    
    // Umweg, weil in UserDefaults nur primitive Datentypen speicherbar
    var namingConventionOrder: NamingConventionOrder {
        get { NamingConventionOrder(rawValue: namingConventionOrderRaw) ?? .titleFirst }
        set { namingConventionOrderRaw = newValue.rawValue }
    }
    
    @Query(sort: \Kuote.pageno) private var kuotes: [Kuote]
    
    @State private var selectedKuote: Kuote? = nil
    
    @Environment(\.modelContext) private var ctx
    @Environment(\.colorScheme) private var colorScheme
    
    @EnvironmentObject var filterVM: FilterHeaderViewModel  // in ContentView einmalig instanziiert
    @EnvironmentObject var navVM: NavigationViewModel // e.g. navVM.presentedBooks für NavigationStack
    @EnvironmentObject var vm: KuotesViewModel

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
                        Text("All Books")
                            .bold()
                            .foregroundStyle(.accent)
                    }
                    .listRowBackground(Color(.secondarySystemGroupedBackground).opacity(0.3))
                    ForEach(bookNames, id: \.self) { bookName in
                        NavigationLink(value: bookName) {
                            BookRow(
                                bookName: bookName,
                                order: namingConventionOrder,
                                separator: namingConventionSeparator
                            )
                        }
                        .listRowBackground(Color(.secondarySystemGroupedBackground).opacity(0.3))
                    }
                }
                .scrollContentBackground(.hidden)
                .background(.kBackground)
                .navigationDestination(for: String.self) { bookName in
                    if bookName == "All Books" {
                        BookKuotesView(
                            selectedKuote: $selectedKuote,
                            bookName: "All Books",
                            kuotes: filteredKuotes,
                        )
                    } else {
                        BookKuotesView(
                            selectedKuote: $selectedKuote,
                            bookName: bookName,
                            kuotes: filteredKuotes.filter {
                                $0.fileItem.displayName == bookName
                            },
                        )
                    }
                }
                .refreshable { await vm.reloadKuotes(ctx: ctx) }
                .navigationTitle("Kuotes")
                .navigationSubtitle("Fetched from \(selectedKuotesFolderPath)")
            }
            .onChange(of: pendingKuoteID) { _, newValue in
                Task {
                    if let id = newValue {
                        if let kuote = vm.getKuote(ctx: ctx, id: id) {
                            navVM.presentedBooks = [kuote.fileItem.displayName] // zugehörige Buchseite im NavStack öffnen
                            selectedKuote = kuote // Buch-Sheet öffnen
                            pendingKuoteID = nil
                        }
                    }
                }
            }

            if selectedKuote == nil {
                FilterHeader()
                    .background(.regularMaterial)
                    .cornerRadius(40)
                    .padding()
                    .padding(.horizontal, 15)
            }
        }
    }
}

private struct BookRow: View {
    let bookName: String
    let order: NamingConventionOrder
    let separator: String

    var body: some View {
        if order == .mixed {
            Text(bookName)
        } else {
            let parts = bookName.components(separatedBy: " \(separator) ")
            if parts.count == 2 {
                let first = order == .titleFirst ? parts[1] : parts[0]
                let second = order == .titleFirst ? parts[0] : parts[1]
                TextLabeled(first, second)
            } else {
                Text("ERROR: Book title does not follow naming convention set in Settings")
                    .foregroundStyle(.red)
            }
        }
    }
}

private struct KuotesView_PreviewContainer: View {
    let container: ModelContainer

    init() {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        self.container = try! ModelContainer(for: Kuote.self, Folder.self, configurations: config)

        // Insert mock data into the in-memory context
        let longKuote = Kuote.templateLong
        let shortKuote = Kuote.templateShort
        let mediumKuote = Kuote.templateMedium
        container.mainContext.insert(longKuote)
        container.mainContext.insert(shortKuote)
        container.mainContext.insert(mediumKuote)
    }

    var body: some View {
        KuotesView(pendingKuoteID: .constant(nil))
            .environmentObject(FilterHeaderViewModel())
            .environmentObject(NavigationViewModel())
            .environmentObject(KuotesViewModel())
            .modelContainer(container)
    }
}

#Preview() {
    KuotesView_PreviewContainer()
}
