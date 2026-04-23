//
//  TextLabeled.swift
//  identeam
//
//  Created by Nico Stern on 10.04.26.
//

import SwiftUI

struct TextLabeled: View {
    let label: String
    let value: String
    
    init(_ label: String, _ value: String) {
        self.label = label
        self.value = value
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .textSelection(.enabled)
                .lineLimit(1)
        }
    }
}

#Preview {
    TextLabeled("Label", "Text Value")
}
