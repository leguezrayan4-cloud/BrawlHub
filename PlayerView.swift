import SwiftUI

struct PlayerProfile: Decodable {
    let tag: String
    let name: String
    let trophies: Int
    let highestTrophies: Int?
    let expLevel: Int?
    let club: Club?
    let brawlers: [OwnedBrawler]?

    struct Club: Decodable {
        let name: String?
    }

    struct OwnedBrawler: Decodable, Identifiable {
        let id: Int
        let name: String
        let power: Int?
        let trophies: Int?
    }
}

struct PlayerView: View {
    @State private var tag = ""
    @State private var profile: PlayerProfile?
    @State private var loading = false
    @State private var errorText: String?
    @FocusState private var fieldFocused: Bool

    private let client = ServerClient()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    HStack(spacing: 10) {
                        TextField("#TAG du joueur", text: $tag)
                            .textInputAutocapitalization(.characters)
                            .autocorrectionDisabled()
                            .submitLabel(.search)
                            .focused($fieldFocused)
                            .onSubmit { search() }
                            .padding(12)
                            .background(Color.white.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 12))

                        Button("Chercher") { search() }
                            .buttonStyle(.borderedProminent)
                            .tint(.yellow)
                            .disabled(tag.trimmingCharacters(in: .whitespaces).isEmpty || loading)
                    }

                    if loading {
                        ProgressView().tint(.yellow)
                    }
                    if let errorText {
                        Text(errorText)
                            .foregroundStyle(.red)
                            .font(.footnote)
                    }
                    if let profile {
                        card(profile)
                    }
                }
                .padding()
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Joueur")
            .dismissKeyboardOnTap()
        }
    }

    private func card(_ p: PlayerProfile) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(p.name)
                .font(.title2.bold())
            Text("#\(p.tag)")
                .font(.footnote)
                .foregroundStyle(.secondary)

            HStack(spacing: 16) {
                stat("Trophées", "\(p.trophies)")
                if let best = p.highestTrophies { stat("Record", "\(best)") }
                if let level = p.expLevel { stat("Niveau", "\(level)") }
            }

            if let club = p.club?.name, !club.isEmpty {
                Text("Club : \(club)")
                    .font(.subheadline)
            }

            if let brawlers = p.brawlers, !brawlers.isEmpty {
                Text("Brawlers")
                    .font(.headline)
                ForEach(brawlers.sorted { ($0.trophies ?? 0) > ($1.trophies ?? 0) }.prefix(10)) { b in
                    HStack {
                        Text(b.name.capitalized)
                        Spacer()
                        Text("🏆 \(b.trophies ?? 0)")
                            .foregroundStyle(.secondary)
                    }
                    .font(.subheadline)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func stat(_ label: String, _ value: String) -> some View {
        VStack(spacing: 2) {
            Text(value).font(.headline)
            Text(label).font(.caption).foregroundStyle(.secondary)
        }
    }

    private func search() {
        fieldFocused = false
        let clean = tag.trimmingCharacters(in: .whitespaces)
        guard !clean.isEmpty else { return }
        loading = true
        errorText = nil
        profile = nil
        Task {
            do {
                profile = try await client.player(tag: clean)
            } catch {
                errorText = (error as? LocalizedError)?.errorDescription ?? "Une erreur est survenue."
            }
            loading = false
        }
    }
}
