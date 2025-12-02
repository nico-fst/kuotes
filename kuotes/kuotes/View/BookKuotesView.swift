//
//  BookKuotesView.swift
//  kuotes
//
//  Created by Nico Stern on 02.12.25.
//

import SwiftUI

struct BookKuotesView: View {
    var bookName: String
    var kuotes: [Kuote]
    @Binding var selectedKuote: Kuote?

    var body: some View {
        FilterHeader()
            .padding()
        
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
                .sensoryFeedback(.selection, trigger: selectedKuote)
                .onTapGesture {
                    selectedKuote = kuote
                }
            }
        }
    }
}

#Preview {
    BookKuotesView(
        bookName: "Atomic Habits",
        kuotes: [.templateLong],
        selectedKuote: .constant(.templateLong),
    )
}
