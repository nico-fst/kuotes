//
//  AppIntent.swift
//  kuotes-widgetExtension
//
//  Created by Nico Stern on 16.11.25.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "title should not be displayed" }
    static var description: IntentDescription { "description should not be displayed" }
    
    @Parameter(title: "Select Color Filter", default: nil)
    var colorFilter: [ColorType]? // funktioniert, weil ColorType: CaseIterable, CaseDisplayRepresentable
    
    @Parameter(title: "Select Drawer Filter", default: nil)
    var drawerFilter: [DrawerType]?
}
