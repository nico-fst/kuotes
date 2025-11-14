//
//  MediumSizeView.swift
//  kuotes-widgetExtension
//
//  Created by Nico Stern on 14.11.25.
//

import SwiftUI
import WidgetKit

struct MediumSizeView: View {
    var entry: SimpleEntry
    
    var body: some View {
        VStack() {
            Text("❝ Every action you take is a vote for the type of person you wish to become. ❞")
                .frame(maxWidth: .infinity, alignment: .leading)
                .opacity(0.7)
            
            Spacer()
            
            Text("~ Atomic Habits (page 38)")
                .font(.footnote)
                .opacity(0.4)
        }
        .padding(8)
        .containerBackground(for: .widget) {
            ContainerRelativeShape()
                .fill(.green.gradient)
        }
    }
}
