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
            Text("❝ \(entry.kuote.text) ❞")
                .frame(maxWidth: .infinity, alignment: .leading)
                .opacity(0.7)
            
            Spacer()
            
            Text(entry.kuote.fileItem.displayName)
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
