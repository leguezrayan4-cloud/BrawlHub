import SwiftUI

@main
struct BrawlHubApp: App {
    var body: some Scene {
        WindowGroup {
            BrawlerListView()
                .preferredColorScheme(.dark)
        }
    }
}
