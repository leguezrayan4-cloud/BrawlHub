import SwiftUI

struct MainTabView: View {
    @State private var selection = 0

    var body: some View {
        TabView(selection: $selection) {
            BrawlerListView()
                .tabItem { Label("Brawlers", systemImage: "square.grid.2x2") }
                .tag(0)

            GameModesView()
                .tabItem { Label("Modes", systemImage: "map") }
                .tag(1)

            UpdatesView()
                .tabItem { Label("Mises à jour", systemImage: "newspaper") }
                .tag(2)

            AIView()
                .tabItem { Label("IA", systemImage: "sparkles") }
                .tag(3)

            ProfileHubView()
                .tabItem { Label("Profil", systemImage: "person.crop.circle") }
                .tag(4)
        }
        .onChange(of: selection) { _ in Haptics.selection() }
    }
}