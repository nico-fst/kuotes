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
    @State private var selectedKuoteWasChanged = false
    
    @Environment(\.modelContext) private var ctx
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
                    ForEach(bookNames, id: \.self) { bookName in
                        NavigationLink(value: bookName) {
                            BookRow(
                                bookName: bookName,
                                order: namingConventionOrder,
                                separator: namingConventionSeparator
                            )
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
                .sheet(item: $selectedKuote, onDismiss: {
                    guard selectedKuoteWasChanged else { return }
                    selectedKuoteWasChanged = false
                    
                    Task {
                        await vm.reloadKuotes(ctx: ctx)
                    }
                }) { kuote in
                    KuoteDetailSheet(kuote: kuote) {
                        selectedKuoteWasChanged = true
                    }
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

private struct KuoteDetailSheet: View {
    let kuote: Kuote
    let onChanged: () -> Void
    
    @EnvironmentObject var filterVM: FilterHeaderViewModel
    @EnvironmentObject var vm: KuotesViewModel
    @Environment(\.modelContext) private var ctx
    
    @State private var selectedDrawer: DrawerType
    @State private var selectedColor: ColorType
    @State private var changeError: String = ""
    @State private var updating: Bool = false
    @State private var didChangeKuote = false
    
    
    init(kuote: Kuote, onChanged: @escaping () -> Void) {
        self.kuote = kuote
        _selectedDrawer = State(initialValue: kuote.drawer) // auto von kuote nehmen
        _selectedColor = State(initialValue: kuote.color) // auto von kuote nehmen
        self.onChanged = onChanged
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 4) {
                Spacer()

                if !updating {
                    Text(kuote.chapter)
                        .font(.headline)
                        .italic()
                    Text(kuote.text)
                        .padding(8)
                        .background(selectedColor.swiftUIColor.opacity(0.3))
                        .cornerRadius(10)
                    Text(verbatim: "\(selectedDrawer) on page \(kuote.pageno)")
                        .font(.subheadline)
                        .opacity(0.3)
                } else {
                    ProgressView("Updating...")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                }
                
                Text(changeError)
                    .foregroundStyle(.red)

                Spacer()

                GlassEffectContainer {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            DrawerPickers(
                                selectedDrawer: Binding(
                                    get: { [selectedDrawer] as Set<DrawerType> },
                                    set: { newSet in
                                        changeError = ""
                                        let newValue = newSet.first ?? selectedDrawer
                                        
                                        // no updates if same color selected
                                        guard newValue != selectedDrawer else { return }
                                        
                                        Task {
                                            do {
                                                updating = true
                                                defer { updating = false }
                                                
                                                let found = try await FetchServices.shared.updateHighlightDrawer(for: kuote, to: newValue)
                                                if !found {
                                                    changeError = "Kuote not found - reload local Kuotes"
                                                }
                                                
                                                selectedDrawer = newValue
                                                didChangeKuote = true
                                                onChanged()
                                            } catch {
                                                selectedDrawer = kuote.drawer // rollback
                                                changeError = error.localizedDescription
                                            }
                                        }
                                    }),
                                allowMulti: false
                            )
                        }
                    }
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ColorPickers(
                                selectedColor: Binding(
                                    get: { [selectedColor] as Set<ColorType> },
                                    set: { newSet in
                                        changeError = ""
                                        let newValue = newSet.first ?? selectedColor
                                        
                                        // no updates if same color selected
                                        guard newValue != selectedColor else { return }
                                        
                                        Task {
                                            do {
                                                updating = true
                                                defer { updating = false }
                                                
                                                let found = try await FetchServices.shared.updateHighlightColor(for: kuote, to: newValue)
                                                if !found {
                                                    changeError = "Kuote not found - reload local Kuotes"
                                                }
                                                
                                                selectedColor = newValue
                                                didChangeKuote = true
                                                onChanged()
                                            } catch {
                                                selectedColor = kuote.color // rollback
                                                changeError = error.localizedDescription
                                            }
                                        }
                                    }),
                                allowMulti: false
                            )
                        }
                    }
                }
            }
            .navigationTitle(kuote.fileItem.displayName)
            .padding()
        }
        .presentationDetents([.medium, .large])
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

