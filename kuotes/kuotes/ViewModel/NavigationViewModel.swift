//
//  NavigationViewModel.swift
//  kuotes
//
//  Created by Nico Stern on 03.12.25.
//

import Foundation
import SwiftUI
import Combine

class NavigationViewModel: ObservableObject {
    @Published var presentedBooks: [String] = []
}
