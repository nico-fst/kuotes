//
//  KuotesView.swift
//  kuotes
//
//  Created by Nico Stern on 16.11.25.
//

import SwiftUI
import SwiftData

struct KuotesView: View {
    @AppStorage("selectedKuotesFolderPath") var selectedKuotesFolderPath: String = ""
    @Environment(\.modelContext) private var modelContext
    @Query private var kuotes: [Kuote]
    @State private var selectedKuote: Kuote? = nil
    @State private var vm: KuotesViewModel? = nil // async mit modelContext befüllt
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(kuotes) { kuote in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(kuote.fileItem.displayName)
                            .fontWeight(.bold)
                        Text(kuote.chapter)
                            .italic()
                        Text(kuote.text)
                            .lineLimit(2)
                    }
                    .onTapGesture {
                        selectedKuote = kuote
                    }
                }
            }
            .task { // weil @Environment bei Initializer oben noch nicht available wäre
                if vm == nil { vm = KuotesViewModel(modelContext: modelContext) }
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
                            .background(kuote.color.swiftUIColor)
                        Text(verbatim: "\(kuote.drawer) on page \(kuote.pageno)") // verbatim constructs non-localized string (localized deprecated)
                            .font(.subheadline)
                            .opacity(0.3)
                        
                        Spacer()
                    }
                    .navigationTitle(kuote.fileItem.displayName)
                    .padding()
                }
                .presentationDetents([.medium, .large])
                .onOpenURL { url in
                    guard
                        url.scheme == "kuotes",
                        url.host == "kuote",
                        url.pathComponents.count > 1
                    else {
                        print("Error opening link: \(url)")
                        return
                    }
                    let id = url.pathComponents[1]
                    
                    selectedKuote = FetchServices.shared.getKuote(id: id)
                }
            }
        }
    }
}

#Preview {
    KuotesView()
}
