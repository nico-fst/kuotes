//
//  kuotes_widget.swift
//  kuotes-widget
//
//  Created by Nico Stern on 13.11.25.
//

import WidgetKit
import SwiftUI

@main
struct kuotes_widget: Widget {
    let kind: String = "kuotes_widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WidgetView(entry: entry)
        }
        .supportedFamilies([.systemMedium])
        .configurationDisplayName("Saved Kuotes")
        .description("View some of your saved Kuotes.")
    }
}

#Preview(as: .systemMedium) {
    kuotes_widget()
} timeline: {
    KuoteEntry(date: .now, kuote: Kuote.templateKuote)
}

