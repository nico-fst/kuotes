//
//  BookKuotesView.swift
//  kuotes
//
//  Created by Nico Stern on 02.12.25.
//

import SwiftUI
import SwiftData

struct BookKuotesView: View {
    @Binding var selectedKuote: Kuote?
    var bookName: String
    var kuotes: [Kuote]
    
    @Environment(\.modelContext) private var ctx
    @EnvironmentObject private var filterVM: FilterHeaderViewModel
    @EnvironmentObject private var vm: KuotesViewModel
    @EnvironmentObject private var bookVM: BookKuotesViewModel
    @Namespace private var kuoteAnimation
    
    func handleTap(on kuote: Kuote) {
        bookVM.prepareForSelection()

        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            selectedKuote = kuote
        }

        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(350))
            guard selectedKuote?.id == kuote.id else { return }

            withAnimation(.easeOut(duration: 0.24)) {
                bookVM.showFullSelectedKuote = true
            }

            try? await Task.sleep(for: .milliseconds(240))
            guard selectedKuote?.id == kuote.id else { return }
            bookVM.showFloatingEffect = true
        }
    }

    func closeSelectedKuote(_ kuote: Kuote) {
        bookVM.showFloatingEffect = false

        withAnimation(.easeOut(duration: 0.22)) {
            bookVM.showFullSelectedKuote = false
        }

        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(220))
            guard selectedKuote?.id == kuote.id else { return }

            bookVM.closingSelectedKuoteID = kuote.id
            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                selectedKuote = nil
            }

            try? await Task.sleep(for: .milliseconds(350))
            guard bookVM.closingSelectedKuoteID == kuote.id else { return }
            bookVM.closingSelectedKuoteID = nil
        }
    }

    var body: some View {
        List {
            Section {
                Picker("Sorting Criteria", selection: $bookVM.sortCriterium) {
                    ForEach(SortCriterium.allCases) { crit in
                        Text(crit.rawValue).tag(crit)
                    }
                }
                .pickerStyle(.menu)

                Picker("Sorting Order", selection: $bookVM.sortOrder) {
                    ForEach(SortOrder.allCases) { order in
                        Text(order.rawValue).tag(order)
                    }
                }
                .pickerStyle(.segmented)
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)

            Section {
                ForEach(bookVM.sortedKuotes(kuotes)) { kuote in
                    let isHidden = bookVM.isRowHidden(
                        kuoteID: kuote.id,
                        selectedKuoteID: selectedKuote?.id
                    )

                    let onSelect: () -> Void = { handleTap(on: kuote) }
                    let onChanged: () -> Void = {
                        if selectedKuote?.id == kuote.id {
                            selectedKuote = kuote
                        }
                        bookVM.didChangeSelectedKuote = true
                    }
                    let onDelete: () -> Void = {
                        Task { await bookVM.deleteKuote(kuote) }
                    }

                    KuoteRow(
                        kuote: kuote,
                        selectedKuote: $selectedKuote,
                        kuoteAnimation: kuoteAnimation,
                        onSelect: onSelect,
                        onChanged: onChanged,
                        onDelete: onDelete
                    )
                    .id(kuote.id)
                    .onChange(of: kuote.color) { _, _ in
                        onChanged()
                    }
                    .opacity(isHidden ? 0 : 1)
                    .allowsHitTesting(!isHidden)
                }
            }
        }
        .listStyle(.plain)
        .background(.kBackground)
        .listRowBackground(Color.clear)
        .onDisappear {
            reloadAfterDeleteIfNeeded()
            reloadAfterSelectedKuoteDismissIfNeeded()
        }
        .onChange(of: selectedKuote?.id) { oldValue, newValue in
            guard oldValue != nil && newValue == nil else { return }
            reloadAfterSelectedKuoteDismissIfNeeded()
        }
        .refreshable { await vm.reloadKuotes(ctx: ctx) }
        .navigationTitle(bookName)
        .alert("Delete failed", isPresented: Binding(
            get: { bookVM.deleteError != nil },
            set: { isPresented in
                if !isPresented {
                    bookVM.deleteError = nil
                }
            }
        )) {
            Button("OK", role: .cancel) {
                bookVM.deleteError = nil
            }
        } message: {
            Text(bookVM.deleteError ?? "An unknown error occurred.")
        }
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: 140)
        }
        .overlay {
            if let _ = selectedKuote {
                selectedKuoteOverlay()
            }
        }
    }
    
    @ViewBuilder
    private func selectedKuoteOverlay() -> some View {
        if let selectedKuote {
            // Help the compiler with explicit constants
            let selectedID = selectedKuote.id
            ZStack {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .ignoresSafeArea()
                    .onTapGesture {
                        closeSelectedKuote(selectedKuote)
                    }

                VStack {
                    Spacer(minLength: 0)

                    let card = KuoteCard(
                        kuote: selectedKuote,
                        detailed: bookVM.showFullSelectedKuote,
                        isFrameFloating: bookVM.showFloatingEffect
                    ) {
                        // Refresh the selected kuote reference to reflect latest color changes
                        if let current = kuotes.first(where: { $0.id == selectedID }) {
                            self.selectedKuote = current
                        }
                        bookVM.didChangeSelectedKuote = true
                    }
                    card
                        .matchedGeometryEffect(id: selectedID, in: kuoteAnimation)
                        .padding(.horizontal, 16)
                        .onTapGesture {
                            closeSelectedKuote(selectedKuote)
                        }

                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.scale.combined(with: .opacity))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        } else {
            EmptyView()
        }
    }

    private func reloadAfterSelectedKuoteDismissIfNeeded() {
        guard bookVM.didChangeSelectedKuote else { return }
        bookVM.didChangeSelectedKuote = false

        Task {
            await vm.reloadKuotes(ctx: ctx)
        }
    }

    private func reloadAfterDeleteIfNeeded() {
        guard bookVM.didDeleteKuote else { return }
        bookVM.didDeleteKuote = false

        Task {
            await vm.reloadKuotes(ctx: ctx)
        }
    }
    
}



#Preview {
    BookKuotesView(
        selectedKuote: .constant(.templateLong),
        bookName: "Atomic Habits",
        kuotes: [.templateLong, .templateMedium, .templateShort],
    )
    .environmentObject(FilterHeaderViewModel())
    .environmentObject(KuotesViewModel())
    .environmentObject(BookKuotesViewModel())
}
