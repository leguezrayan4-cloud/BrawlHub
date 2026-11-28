import SwiftUI

struct ProfileHubView: View {
    @State private var showPlayer = false
    @State private var showAccount = false

    var body: some View {
        NavigationStack {
            List {
                Button {
                    showPlayer = true
                } label: {
                    Label("Recherche de joueur", systemImage: "magnifyingglass")
                }

                Button {
                    showAccount = true
                } label: {
                    Label("Compte", systemImage: "person.crop.circle")
                }
            }
            .navigationTitle("Profil")
            .sheet(isPresented: $showPlayer) {
                PlayerView()
            }
            .sheet(isPresented: $showAccount) {
                AccountView()
            }
        }
    }
}