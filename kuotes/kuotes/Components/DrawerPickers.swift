//
//  ColorPickerRow.swift
//  kuotes
//
//  Created by Nico Stern on 24.04.26.
//

import SwiftUI

struct DrawerPickers: View {
    @Binding var selectedDrawer: Set<DrawerType>
    let allowMulti: Bool
    
    var body: some View {
        ForEach(DrawerType.allCases, id: \.self) { type in
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    toggle(type)
                }
            }) {
                Text(type.rawValue)
                    .padding(13)
                    .foregroundStyle(
                        Color("AccentColor").opacity(0.9)
                    )
            }
            .sensoryFeedback(
                .selection,
                trigger: selectedDrawer
            )
            .glassEffect(
                .regular.tint(
                    selectedDrawer.contains(type)
                        ? Color("AccentColor").opacity(0.35)
                        : Color("AccentColor").opacity(0.1)
                ).interactive()
            )
        }
    }
    
    private func toggle(_ type: DrawerType) {
        if allowMulti {
            if selectedDrawer.contains(type) {
                selectedDrawer.remove(type)
            } else {
                selectedDrawer.insert(type)
            }
        } else {
            // Single Selection
            if selectedDrawer.contains(type) {
                selectedDrawer.removeAll()
            } else {
                selectedDrawer = [type]
            }
        }
    }
}

#Preview {
    @Previewable @State var selected: Set<DrawerType> = [.lighten]

    DrawerPickers(
        selectedDrawer: $selected,
        allowMulti: true
    )
}
