//
//  HotProspectsApp.swift
//  HotProspects
//
//  Created by Julia Martcenko on 24/03/2025.
//

import SwiftUI
import SwiftData

@main
struct HotProspectsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
		.modelContainer(for: Prospect.self)
    }
}
