//
//  BookKuotesView.swift
//  kuotes
//
//  Created by Nico Stern on 02.12.25.
//

import SwiftUI
import SwiftData

struct BookKuotesView: View {
    var bookName: String
    var kuotes: [Kuote]
    @Binding var selectedKuote: Kuote?
    
    @Environment(\.modelContext) private var ctx
    @EnvironmentObject private var filterVM: FilterHeaderViewModel
    @EnvironmentObject private var vm: KuotesViewModel

    enum SortOrder: String, CaseIterable, Identifiable {
        case ascending = "Ascending"
        case descending = "Descending"

        var id: String { rawValue }
    }
    
    @State private var sortOrder: SortOrder = .ascending
    
    @State private var didDeleteKuote: Bool = false
    @State private var deleteError: String? = nil

    enum SortCriterium: String, CaseIterable, Identifiable {
        case page = "Page"
        case date = "Creation Date"

        var id: String { rawValue }
    }
    @State private var sortCriterium: SortCriterium = .page

    var sortedKuotes: [Kuote] {
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

    var body: some View {
        List {
            Section {
                Picker("Sorting Criteria", selection: $sortCriterium) {
                    ForEach(SortCriterium.allCases) { crit in
                        Text(crit.rawValue).tag(crit)
                    }
                }
                .pickerStyle(.menu)

                Picker("Sorting Order", selection: $sortOrder) {
                    ForEach(SortOrder.allCases) { order in
                        Text(order.rawValue).tag(order)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section {
                ForEach(sortedKuotes) { kuote in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(kuote.fileItem.displayName)
                            .fontWeight(.bold)
                        Text(kuote.chapter)
                            .italic()
                        Text(kuote.text)
                            .lineLimit(2)
                        Text(
                            "Added \(kuote.datetime.formatted(.dateTime.year().month().day().hour().minute())) on page \(kuote.pageno)"
                        )
                        .font(.footnote)
                    }
                    .sensoryFeedback(.selection, trigger: selectedKuote)
                    .onTapGesture {
                        selectedKuote = kuote
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            Task {
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
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .onDisappear {
            guard didDeleteKuote else { return }
            Task {
                await vm.reloadKuotes(ctx: ctx)
            }
        }
        .refreshable { await vm.reloadKuotes(ctx: ctx) }
        .navigationTitle(bookName)
        .alert("Delete failed", isPresented: Binding(
            get: { deleteError != nil },
            set: { isPresented in
                if !isPresented {
                    deleteError = nil
                }
            }
        )) {
            Button("OK", role: .cancel) {
                deleteError = nil
            }
        } message: {
            Text(deleteError ?? "An unknown error occurred.")
        }
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: 140)
        }
    }
}

#Preview {
    BookKuotesView(
        bookName: "Atomic Habits",
        kuotes: [.templateLong, .templateMedium, .templateShort],
        selectedKuote: .constant(.templateLong),
    )
    .environmentObject(FilterHeaderViewModel())
    .environmentObject(KuotesViewModel())
}
