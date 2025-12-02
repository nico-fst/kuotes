//
//  FilterHeader.swift
//  kuotes
//
//  Created by Nico Stern on 02.12.25.
//

import SwiftData
import SwiftUI

struct FilterHeader: View {
    @Query(sort: \Kuote.pageno) private var kuotes: [Kuote]
    @EnvironmentObject var filterVM: FilterHeaderViewModel  // in ContentView einmalig instanziiert

    var body: some View {
        GlassEffectContainer {
            VStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(DrawerType.allCases, id: \.self) { type in
                            Button(action: { filterVM.toggleDrawer(type) }) {
                                Text(type.rawValue)
                                    .padding(13)
                                    .foregroundStyle(
                                        Color("AccentColor").opacity(0.9)
                                    )
                            }
                            .sensoryFeedback(
                                .selection,
                                trigger: filterVM.selectedDrawerFilter
                            )
                            .glassEffect(
                                .regular.tint(
                                    filterVM.selectedDrawerFilter.contains(type)
                                        ? Color("AccentColor").opacity(0.35)
                                        : Color("AccentColor").opacity(0.1)
                                ).interactive()
                            )
                        }
                    }
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(ColorType.allCases, id: \.self) { type in  // id weil muss für ForEach zu Identifiable konform
                            Button(action: { filterVM.toggleColor(type) }) {
                                Text("●")
                                    .frame(width: 48, height: 48)
                                    .foregroundStyle(
                                        type.swiftUIColor.opacity(0.9)
                                    )
                            }
                            .sensoryFeedback(
                                .selection,
                                trigger: filterVM.selectedColorFilter
                            )
                            .glassEffect(
                                .regular.tint(
                                    filterVM.selectedColorFilter.contains(type)
                                        ? type.swiftUIColor.opacity(0.35)
                                        : type.swiftUIColor.opacity(0.1)
                                ).interactive()
                            )
                        }
                    }
                }
            }
        }
        .padding()
    }
}

#Preview {
    FilterHeader()
}
