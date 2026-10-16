//
//  SimplerLoggerApp.swift
//  SimplerLogger
//
//  Created by David Rynn on 5/22/22.
//

import SwiftUI

@main
struct SimplerLoggerApp: App {
    @StateObject var dataController = DataController()

    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .environmentObject(dataController)
        }
    }
}
