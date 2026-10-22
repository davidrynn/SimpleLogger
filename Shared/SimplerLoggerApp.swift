//
//  SimplerLoggerApp.swift
//  SimplerLogger
//
//  Created by David Rynn on 5/22/22.
//

import SwiftData
import SwiftUI

/// The entry point for both the iPhone and watch apps; each target supplies its own `MainView`.
///
/// Launch arguments: `-UITestInMemoryStore` starts empty in memory; `-SeedSampleData` (Debug only) starts in
/// memory with sample logs.
@main
struct SimplerLoggerApp: App {
    /// A failure is kept, not thrown, so the app can explain it rather than crash.
    private let container: Result<ModelContainer, Error>

    init() {
        // UI tests launch with this argument so they start from an empty store and never touch real data.
        let arguments = ProcessInfo.processInfo.arguments
        let seedSampleData = arguments.contains("-SeedSampleData")
        let inMemory = seedSampleData || arguments.contains("-UITestInMemoryStore")
        container = Result {
            let container = try ModelContainer.simplerLogger(inMemory: inMemory)
            #if DEBUG
            if seedSampleData { try LogStore(context: container.mainContext).seedSampleData() }
            #endif
            return container
        }
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
            Label("Can't Open Your Counters", systemImage: "exclamationmark.triangle")
        } description: {
            Text("Your counters couldn't be loaded. Restart the app, and if that doesn't help, check that there's free storage space.\n\n\(error.localizedDescription)")
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
