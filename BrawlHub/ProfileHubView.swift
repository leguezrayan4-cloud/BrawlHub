import SwiftUI

struct ProfileHubView: View {
    @AppStorage("savedPlayerTag") var savedPlayerTag = ""
    @AppStorage("onboardingDone") var onboardingDone = true
    @AppStorage("hapticsEnabled") var hapticsEnabled = true
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
                                Haptics.tap()
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
                                    Haptics.tap()
                                    tagInput = savedPlayerTag
                                    showTagEdit = true
                                } label: {
                                    Image(systemName: "pencil")
                                        .foregroundStyle(.secondary)
                                }
                            }
                            Button {
                                Haptics.tap()
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
                        Button { Haptics.tap(); showPlayer = true } label: {
                            Label("Rechercher un joueur", systemImage: "magnifyingglass")
                        }
                    } header: {
                        Text("Joueurs")
                    }

                    // Compte
                    Section {
                        Button { Haptics.tap(); showAccount = true } label: {
                            Label("Compte BrawlHub", systemImage: "person.crop.circle")
                        }
                    } header: {
                        Text("Mon compte")
                    }

                    // Réglages
                    Section {
                        Toggle(isOn: $hapticsEnabled) {
                            Label("Vibrations", systemImage: "iphone.radiowaves.left.and.right")
                        }
                        .tint(.yellow)
                        .onChange(of: hapticsEnabled) { on in
                            if on { Haptics.impact(.medium) }
                        }
                    } header: {
                        Text("Réglages")
                    }

                    // Onboarding
                    Section {
                        Button {
                            Haptics.impact(.soft)
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
                    Haptics.success()
                    savedPlayerTag = tagInput.uppercased().replacingOccurrences(of: "#", with: "")
                }
                Button("Annuler", role: .cancel) {}
            } message: {
                Text("Entre ton tag pour lier ton compte Brawl Stars.")
            }
        }
    }
}
