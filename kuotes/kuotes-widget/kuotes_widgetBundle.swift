//
//  kuotes_widgetBundle.swift
//  kuotes-widget
//
//  Created by Nico Stern on 13.11.25.
//

import WidgetKit
import SwiftUI

@main
struct kuotes_widgetBundle: WidgetBundle {
    var body: some Widget {
        kuotes_widget()
        kuotes_widgetControl()
        kuotes_widgetLiveActivity()
    }
}
