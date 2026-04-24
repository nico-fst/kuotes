//
//  ColorPickers.swift
//  kuotes
//
//  Created by Nico Stern on 24.04.26.
//

import SwiftUI

struct ColorPickers: View {
    @Binding var selectedColor: Set<ColorType>
    let allowMulti: Bool
    
    var body: some View {
        ForEach(ColorType.allCases, id: \.self) { type in  // id weil muss für ForEach zu Identifiable konform
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    toggle(type)
                }
            }) {
                Text("●")
                    .font(.title2)
                    .frame(width: 48, height: 48)
                    .foregroundStyle(
                        selectedColor.contains(type)
                        ? type.swiftUIColor
                        : type.swiftUIColor.opacity(0.3)
                    )
            }
            .sensoryFeedback(
                .selection,
                trigger: selectedColor
            )
            .glassEffect(
                .regular.tint(
                    selectedColor.contains(type)
                        ? type.swiftUIColor.opacity(0.35)
                        : type.swiftUIColor.opacity(0.1)
                ).interactive()
            )
        }
    }
    
    private func toggle(_ type: ColorType) {
        if allowMulti {
            if selectedColor.contains(type) {
                selectedColor.remove(type)
            } else {
                selectedColor.insert(type)
            }
        } else {
            // Single Selection
            if selectedColor.contains(type) {
                selectedColor.removeAll()
            } else {
                selectedColor = [type]
            }
        }
    }
}

#Preview {
    @Previewable @State var selected: Set<ColorType> = [.yellow, .blue]

    ColorPickers(
        selectedColor: $selected,
        allowMulti: true
    )
}
