//
//  TextFieldLabeled.swift
//  kuotes
//
//  Created by Nico Stern on 28.04.26.
//

import SwiftUI

struct TextFieldLabeled: View {
    let label: String
    @Binding var value: String
    let placeholder: String?

    init(_ label: String, _ value: Binding<String>, _ placeholder: String? = nil) {
        self.label = label
        self._value = value
        self.placeholder = placeholder
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
                .font(.caption)
                .opacity(0.5)
            
            TextField(placeholder ?? "", text: $value)
                .textSelection(.enabled)
                .lineLimit(1)
        }
    }
}

#Preview {
    TextFieldLabeled("Label", .constant("Preview"), "Placeholder")
}
