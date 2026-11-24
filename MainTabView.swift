import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            BrawlerListView()
                .tabItem { Label("Brawlers", systemImage: "square.grid.2x2") }

            PlayerView()
                .tabItem { Label("Joueur", systemImage: "magnifyingglass") }

            AIView()
                .tabItem { Label("IA", systemImage: "sparkles") }

            AccountView()
                .tabItem { Label("Compte", systemImage: "person.crop.circle") }
        }
    }
}
