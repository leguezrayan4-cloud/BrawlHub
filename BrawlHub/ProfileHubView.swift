import SwiftUI

struct ProfileHubView: View {
    @AppStorage("savedPlayerTag") var savedPlayerTag = ""
    @AppStorage("onboardingDone") var onboardingDone = true
    @State private var showPlayer = false
    @State private var showAccount = false
    @State private var showTagEdit = false
    @State private var tagInput = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.07, green: 0.07, blue: 0.12).ignoresSafeArea()
                List {
                    // Tag lié
                    Section {
                        if savedPlayerTag.isEmpty {
                            Button {
                                tagInput = ""
                                showTagEdit = true
                            } label: {
                                Label("Lier mon tag Brawl Stars", systemImage: "link")
                                    .foregroundStyle(.yellow)
                            }
                        } else {
                            HStack {
                                Label("#\(savedPlayerTag)", systemImage: "person.crop.circle.fill")
                                    .font(.headline)
                                Spacer()
                                Button {
                                    tagInput = savedPlayerTag
                                    showTagEdit = true
                                } label: {
                                    Image(systemName: "pencil")
                                        .foregroundStyle(.secondary)
                                }
                            }
                            Button {
                                showPlayer = true
                            } label: {
                                Label("Voir mes stats", systemImage: "chart.bar.fill")
                            }
                        }
                    } header: {
                        Text("Mon compte Brawl Stars")
                    }

                    // Recherche
                    Section {
                        Button { showPlayer = true } label: {
                            Label("Rechercher un joueur", systemImage: "magnifyingglass")
                        }
                    } header: {
                        Text("Joueurs")
                    }

                    // Compte
                    Section {
                        Button { showAccount = true } label: {
                            Label("Compte BrawlHub", systemImage: "person.crop.circle")
                        }
                    } header: {
                        Text("Mon compte")
                    }

                    // Onboarding
                    Section {
                        Button {
                            onboardingDone = false
                        } label: {
                            Label("Revoir l'introduction", systemImage: "arrow.counterclockwise")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Profil")
            .sheet(isPresented: $showPlayer) {
                PlayerView(initialTag: savedPlayerTag)
            }
            .sheet(isPresented: $showAccount) {
                AccountView()
            }
            .alert("Mon tag Brawl Stars", isPresented: $showTagEdit) {
                TextField("#XXXXXXXX", text: $tagInput)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                Button("Enregistrer") {
                    savedPlayerTag = tagInput.uppercased().replacingOccurrences(of: "#", with: "")
                }
                Button("Annuler", role: .cancel) {}
            } message: {
                Text("Entre ton tag pour lier ton compte Brawl Stars.")
            }
        }
    }
}
