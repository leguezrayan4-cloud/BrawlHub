import SwiftUI

struct MockMap: Identifiable {
    let id = UUID()
    let name: String
}

struct MockMode: Identifiable {
    let id = UUID()
    let name: String
    let summary: String
    let icon: String
    let maps: [MockMap]
}

struct MockUpdate: Identifiable {
    let id = UUID()
    let title: String
    let version: String
    let date: String
    let summary: String
    let details: [String]
}

enum MockData {
    static let modes: [MockMode] = [
        MockMode(name: "Gem Grab", summary: "Collectez 10 gemmes et tenez bon pour remporter la victoire.", icon: "diamond.fill",
                 maps: [MockMap(name: "Hard Rock Mine"), MockMap(name: "Undermine"), MockMap(name: "Crystal Arcade")]),
        MockMode(name: "Brawl Ball", summary: "Marquez 2 buts avant l'équipe adverse.", icon: "soccerball",
                 maps: [MockMap(name: "Super Stadium"), MockMap(name: "Backyard Bowl")]),
        MockMode(name: "Heist", summary: "Attaquez le coffre ennemi ou défendez le vôtre.", icon: "lock.fill",
                 maps: [MockMap(name: "Safe Zone"), MockMap(name: "Kaboom Canyon")]),
        MockMode(name: "Bounty", summary: "Éliminez des ennemis pour accumuler des étoiles.", icon: "star.fill",
                 maps: [MockMap(name: "Layer Cake"), MockMap(name: "Shooting Star")]),
        MockMode(name: "Showdown", summary: "Le dernier survivant remporte la partie.", icon: "figure.run",
                 maps: [MockMap(name: "Skull Creek"), MockMap(name: "Feast or Famine"), MockMap(name: "Cavern Churn")]),
    ]

    static let updates: [MockUpdate] = [
        MockUpdate(title: "Saison Hypercharge", version: "58.0", date: "1 novembre 2026",
                   summary: "Nouvelle saison avec des hypercharges inédites pour 8 brawlers.",
                   details: ["8 nouvelles hypercharges", "Nouveau mode temporaire : Wipeout", "Équilibrage général", "Nouveau brawler : Juju"]),
        MockUpdate(title: "Mise à jour Halloween", version: "57.5", date: "15 octobre 2026",
                   summary: "Événements spéciaux Halloween et skins limités.",
                   details: ["5 skins Halloween exclusifs", "Mode Zombie Brawl temporaire", "Corrections de bugs"]),
        MockUpdate(title: "Patch équilibrage", version: "57.2", date: "1 octobre 2026",
                   summary: "Ajustements de 20 brawlers suite aux retours de la communauté.",
                   details: ["Nerf de Mico et Melodie", "Buff de Buster et Gray", "Correction du bug de téléportation"]),
    ]
}
