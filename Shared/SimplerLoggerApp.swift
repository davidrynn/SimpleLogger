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
    private let container: Result<ModelContainer, Error>

    init() {
        // UI tests launch with this argument so they start from an empty store and never touch real data.
        let inMemory = ProcessInfo.processInfo.arguments.contains("-UITestInMemoryStore")
        container = Result { try .simplerLogger(inMemory: inMemory) }
    }

    var body: some Scene {
        WindowGroup {
            switch container {
            case .success(let container):
                MainView()
                    .modelContainer(container)
            case .failure(let error):
                StoreUnavailableView(error: error)
            }
        }
    }
}

/// Shown instead of crashing when the store can't be opened.
private struct StoreUnavailableView: View {
    let error: Error

    var body: some View {
        ContentUnavailableView {
            Label("Can't Open Your Logs", systemImage: "exclamationmark.triangle")
        } description: {
            Text("Your logs couldn't be loaded. Restart the app, and if that doesn't help, check that there's free storage space.\n\n\(error.localizedDescription)")
        }
    }
}

extension View {
    /// Presents `error` as an alert and clears it when dismissed.
    func errorAlert(_ error: Binding<Error?>) -> some View {
        alert(
            "Something Went Wrong",
            isPresented: Binding(get: { error.wrappedValue != nil }, set: { if !$0 { error.wrappedValue = nil } }),
            presenting: error.wrappedValue
        ) { _ in
            Button("OK") {}
        } message: { error in
            Text(error.localizedDescription)
        }
    }
}
