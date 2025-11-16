//
//  FolderView.swift
//  kuotes
//
//  Created by Nico Stern on 16.11.25.
//

import SwiftUI
import SwiftData

struct FolderView: View {
    @AppStorage("selectedKuotesFolderPath") var selectedKuotesFolderPath: String = ""
    @Query private var folders: [Folder]
    @Environment(\.modelContext) private var modelContext
    @State private var vm: FolderViewModel? = nil
    
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
                            }
                        } label: {
                            Text(folder.name)
                        }
                    }
                    Text("Only the top-level folder will be listed here. Set the URL manually when using a subfolder or no folder is listed here.")
                        .foregroundColor(.red)
                        .font(.footnote)
                }
                .task { // weil @Environment bei Initializer oben noch nicht available wäre
                    if vm == nil { vm = FolderViewModel(modelContext: modelContext) }
                }
                .refreshable { await vm?.reloadFolders() }
                .navigationTitle("Select Kuotes Folder")
                .navigationSubtitle("Or set the absolute URL in Settings")
            }
        }
    }
}

#Preview {
    FolderView()
}
