//
//  FolderView.swift
//  kuotes
//
//  Created by Nico Stern on 16.11.25.
//

import SwiftData
import SwiftUI

struct FolderView: View {
    let onSelected: () -> Void
    @AppStorage("selectedKuotesFolderPath") var selectedKuotesFolderPath:
        String = ""
    
    @Query private var folders: [Folder]
    
    @Environment(\.modelContext) private var ctx
    @EnvironmentObject private var vm: FolderViewModel
    
    init(onSelected: @escaping () -> Void = {}) {
        self.onSelected = onSelected
    }

    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(folders) { folder in
                        NavigationLink {
                            Text(folder.href.absoluteString)
                                .fontWeight(.bold)
                            Button("Select this folder") {
                                selectedKuotesFolderPath = folder.href.absoluteString
                                onSelected()
                            }
                        } label: {
                            Text(folder.name)
                        }
                        .listRowBackground(Color(.secondarySystemGroupedBackground).opacity(0.3))
                    }
                    Text(
                        "Only the top-level folder will be listed here. Set the URL manually when using a subfolder or no folder is listed here."
                    )
                    .foregroundColor(Color("AccentColor"))
                    .font(.footnote)
                    .listRowBackground(Color(.secondarySystemGroupedBackground).opacity(0.3))
                }
                .scrollContentBackground(.hidden)
                .background(.kBackground)
                .refreshable { await vm.reloadFolders(ctx: ctx) }
                .navigationTitle("Select Kuotes Folder")
                .navigationSubtitle("Or set the absolute URL in Settings")
            }
        }
    }
}

#Preview {
    FolderView()
        .environmentObject(FolderViewModel())
}
