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
    @EnvironmentObject var filterVM: FilterHeaderViewModel  // in ContentView einmalig instanziiert
    @EnvironmentObject var navVM: NavigationViewModel // e.g. navVM.presentedBooks für NavigationStack
    @EnvironmentObject private var vm: KuotesViewModel

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
                        let parts = bookName.components(separatedBy: " - ")
                        
                        NavigationLink(value: bookName) {
                            if namingConventionOrder == .mixed {
                                Text(bookName)
                            } else {
                                let parts = bookName.components(separatedBy: " \(namingConventionSeparator) ")
                                if parts.count == 2 {
                                    TextLabeled(
                                        namingConventionOrder == .titleFirst ? parts[1] : parts[0],
                                        namingConventionOrder == .titleFirst ? parts[0] : parts[1],
                                    )
                                } else {
                                    Text("ERROR: Book title does not follow naming convention set in Settings")
                                        .foregroundStyle(.red)
                                }
                            }
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
                .refreshable { await vm.reloadKuotes(ctx: ctx) }
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
                        if let kuote = vm.getKuote(ctx: ctx, id: id) {
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
            .modelContainer(container)
    }
}

#Preview() {
    KuotesView_PreviewContainer()
}
