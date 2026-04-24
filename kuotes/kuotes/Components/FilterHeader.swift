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
    @EnvironmentObject var filterVM: FilterHeaderViewModel

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
                        DrawerPickers(selectedDrawer: $filterVM.selectedDrawerFilter, allowMulti: true)
                    }
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ColorPickers(selectedColor: $filterVM.selectedColorFilter, allowMulti: true)
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
