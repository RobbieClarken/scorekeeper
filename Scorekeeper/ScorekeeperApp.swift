import Dependencies
import SwiftUI

@main
struct ScorekeeperApp: App {
    init() {
        prepareDependencies {
            // swiftlint:disable:next force_try
            try! $0.bootstrapDatabase()
        }
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                GamesView()
            }
        }
    }
}
