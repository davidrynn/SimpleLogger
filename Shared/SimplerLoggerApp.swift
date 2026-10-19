//
//  SimplerLoggerApp.swift
//  SimplerLogger
//
//  Created by David Rynn on 5/22/22.
//

import SwiftData
import SwiftUI

@main
struct SimplerLoggerApp: App {
    let container: ModelContainer

    init() {
        do {
            container = try .simplerLogger()
        } catch {
            fatalError("Failed to create the model container: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            MainView()
        }
        .modelContainer(container)
    }
}
