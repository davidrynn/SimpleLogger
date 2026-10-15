//
//  SimplerLoggerApp.swift
//  SimplerLogger
//
//  Created by David Rynn on 5/22/22.
//

import SwiftUI
import UIKit

//let quickActionSettings = QuickActionService()
//var shortcutItemToProcess: UIApplicationShortcutItem?

@main
struct SimplerLoggerApp: App {
    @StateObject var dataController = DataController()
    @Environment(\.scenePhase) var scenePhase
//    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
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

//
//final class AppDelegate: NSObject, UIApplicationDelegate {
//    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
//        if let shortcutItem = options.shortcutItem {
//            shortcutItemToProcess = shortcutItem
//        }
//        
//        let sceneConfiguration = UISceneConfiguration(name: "Custom Configuration", sessionRole: connectingSceneSession.role)
//        sceneConfiguration.delegateClass = CustomSceneDelegate.self
//        
//        return sceneConfiguration
//    }
//}
//
//final class CustomSceneDelegate: UIResponder, UIWindowSceneDelegate {
//    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
//        shortcutItemToProcess = shortcutItem
//    }
//}
