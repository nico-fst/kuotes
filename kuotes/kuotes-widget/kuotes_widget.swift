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
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            WidgetView(entry: entry)
        }
        .supportedFamilies([.systemMedium, .systemLarge])
        .configurationDisplayName("Saved Kuotes")
        .description("View some of your saved Kuotes.")
    }
}

extension ConfigurationAppIntent {
    // fileprivate: nur in dieser Datei sichtbar
    fileprivate static var templateUnfiltered: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        return intent
    }
    
    fileprivate static var templateGray: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.colorFilter = [.gray]
        return intent
    }
}

#Preview(as: .systemMedium) {
    kuotes_widget()
} timeline: {
    KuoteEntry(date: .now, kuote: Kuote.templateShort, configuration: .templateGray)
    KuoteEntry(date: .now, kuote: Kuote.templateLong, configuration: .templateGray)
}

#Preview(as: .systemLarge) {
    kuotes_widget()
} timeline: {
    KuoteEntry(date: .now, kuote: Kuote.templateShort, configuration: .templateGray)
    KuoteEntry(date: .now, kuote: Kuote.templateLong, configuration: .templateGray)
}
