//
//  WidgetView.swift
//  kuotes
//
//  Created by Nico Stern on 14.11.25.
//

import SwiftUI
import WidgetKit

struct WidgetView: View {
    @Environment(\.widgetFamily) var widgetFamily
    var entry: Provider.Entry

    var body: some View {
        switch widgetFamily {
        case .systemMedium:
          MediumSizeView(entry: entry)
        default:
            Text("Never executed, but switch has to be exhaustive")
        }
    }
}
