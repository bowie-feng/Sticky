import SwiftUI

@main
struct StickyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // No visible scene — all windows are managed by AppDelegate manually.
        // Using an empty WindowGroup that never opens prevents SwiftUI from
        // creating a default window or overriding our custom menu.
        WindowGroup {
            EmptyView()
                .hidden()
        }
        .defaultAppStorage(.init())
    }
}
