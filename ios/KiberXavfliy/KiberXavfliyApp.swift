import SwiftUI

@main
struct KiberXavfliyApp: App {
    init() {
        RustBridge.initialize()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
