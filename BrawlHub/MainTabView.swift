import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            BrawlerListView()
                .tabItem { Label("Brawlers", systemImage: "square.grid.2x2") }

            GameModesView()
                .tabItem { Label("Modes", systemImage: "map") }

            UpdatesView()
                .tabItem { Label("Mises à jour", systemImage: "newspaper") }

            AIView()
                .tabItem { Label("IA", systemImage: "sparkles") }

            ProfileHubView()
                .tabItem { Label("Profil", systemImage: "person.crop.circle") }
        }
    }
}