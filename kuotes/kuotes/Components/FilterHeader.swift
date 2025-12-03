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

    private var filterString: String? {
        let colorCount = filterVM.selectedColorFilter.count
        let drawerCount = filterVM.selectedDrawerFilter.count

        if colorCount == 0 && drawerCount == 0 {
            return nil
        }

        let colorText: String
        if colorCount == 0 {
            colorText = ""
        } else if colorCount == 1 {
            colorText = "1 color"
        } else {
            colorText = "\(colorCount) colors"
        }

        let drawerText: String
        if drawerCount == 0 {
            drawerText = ""
        } else if drawerCount == 1 {
            drawerText = "1 drawer"
        } else {
            drawerText = "\(drawerCount) drawers"
        }

        switch (colorText.isEmpty, drawerText.isEmpty) {
        case (false, false):
            return "Filtered by \(colorText) && \(drawerText)"
        case (false, true):
            return "Filtered by \(colorText)"
        case (true, false):
            return "Filtered by \(drawerText)"
        default:
            return nil  // nie erreicht
        }
    }

    var body: some View {
        GlassEffectContainer {
            VStack {
                if let filterString {
                    Text(filterString)
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(DrawerType.allCases, id: \.self) { type in
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    filterVM.toggleDrawer(type)
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
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    filterVM.toggleColor(type)
                                }
                            }) {
                                Text("●")
                                    .font(.title2)
                                    .frame(width: 48, height: 48)
                                    .foregroundStyle(
                                        filterVM.selectedColorFilter.contains(type)
                                        ? type.swiftUIColor
                                        : type.swiftUIColor.opacity(0.3)
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
        .environmentObject(FilterHeaderViewModel())
}
