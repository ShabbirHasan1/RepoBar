import SwiftUI

@main
struct RepoBariOSApp: App {
    @State private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            RootView(appModel: appModel)
        }
    }
}
