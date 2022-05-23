//
//  SimpleLoggerApp.swift
//  SimpleLogger
//
//  Created by David Rynn on 5/22/22.
//

import SwiftUI

@main
struct SimpleLoggerApp: App {
    @StateObject var dataController = DataController()

    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
        }
    }
}
