import SwiftUI

struct BrawlersResponse: Decodable {
    let list: [Brawler]
}

struct Brawler: Decodable, Identifiable {
    let id: Int
    let name: String
    let imageUrl: String?
    let description: String?
    let rarity: Tag?
    let brawlerClass: Tag?
    let starPowers: [Ability]?
    let gadgets: [Ability]?

    enum CodingKeys: String, CodingKey {
        case id, name, imageUrl, description, rarity, starPowers, gadgets
        case brawlerClass = "class"
    }

    struct Tag: Decodable {
        let name: String?
        let color: String?
    }

    struct Ability: Decodable, Identifiable {
        let name: String
        let description: String?
        let imageUrl: String?
        var id: String { name }
    }

    var displayName: String { name.capitalized }
    var rarityColor: Color { Color(hex: rarity?.color ?? "#888888") }
}

extension Color {
    init(hex: String) {
        let s = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var v: UInt64 = 0
        Scanner(string: s).scanHexInt64(&v)
        self.init(
            red: Double((v >> 16) & 0xFF) / 255,
            green: Double((v >> 8) & 0xFF) / 255,
            blue: Double(v & 0xFF) / 255
        )
    }
}

@MainActor
final class BrawlerStore: ObservableObject {
    @Published var brawlers: [Brawler] = []
    @Published var loading = false
    @Published var error: String?

    func load() async {
        loading = true
        error = nil
        do {
            let url = URL(string: "https://api.brawlify.com/v1/brawlers")!
            let (data, _) = try await URLSession.shared.data(from: url)
            let res = try JSONDecoder().decode(BrawlersResponse.self, from: data)
            brawlers = res.list.sorted { $0.name < $1.name }
        } catch {
            self.error = "Impossible de charger les brawlers. Vérifie ta connexion."
        }
        loading = false
    }
}
