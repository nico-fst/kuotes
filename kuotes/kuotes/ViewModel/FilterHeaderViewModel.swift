//
//  FilterHeaderViewModel.swift
//  kuotes
//
//  Created by Nico Stern on 02.12.25.
//

import Foundation
import SwiftUI
import Combine

class FilterHeaderViewModel: ObservableObject {
    @Published var selectedColorFilter: Set<ColorType> = []
    @Published var selectedDrawerFilter: Set<DrawerType> = []
    
    func toggleColor(_ color: ColorType) {
        if selectedColorFilter.contains(color) {
            selectedColorFilter.remove(color)
        } else {
            selectedColorFilter.insert(color)
        }
    }
    
    func toggleDrawer(_ drawer: DrawerType) {
        if selectedDrawerFilter.contains(drawer) {
            selectedDrawerFilter.remove(drawer)
        } else {
            selectedDrawerFilter.insert(drawer)
        }
    }
}
