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
    @Environment(\.scenePhase) var scenePhase

    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .environmentObject(dataController)
        }
        .onChange(of: scenePhase) { scenePhase in
            switch scenePhase {
            case .background: addDynamicQuickActions()
            default: return
            }
        }
    }
    
    private func addDynamicQuickActions() {
    #if os(iOS)
        UIApplication.shared.shortcutItems = [
            UIApplicationShortcutItem(
                type: "newEntry",
                localizedTitle: "New Entry",
                localizedSubtitle: nil,
                icon: UIApplicationShortcutIcon(type: .add),
                userInfo: nil
            )
        ]
    #endif
    }
}

enum QuickAction: String {
    case newEntry
}

final class QuickActionService: ObservableObject {
    @Published var action: QuickAction?

    init(initialValue: QuickAction? = nil) {
        action = initialValue
    }
}
