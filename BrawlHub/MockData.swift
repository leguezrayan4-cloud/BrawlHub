import SwiftUI

struct MockMap: Identifiable {
    let id = UUID()
    let name: String
}

struct MockMode: Identifiable {
    let id = UUID()
    let name: String
    let summary: String
    let maps: [MockMap]
}

struct MockUpdate: Identifiable {
    let id = UUID()
    let title: String
    let date: String
    let summary: String
    let details: [String]
}

enum MockData {
    static let modes: [MockMode] = [
        MockMode(
            name: "Mode 1",
            summary: "Description de démonstration du mode 1.",
            maps: [MockMap(name: "Carte 1"), MockMap(name: "Carte 2"), MockMap(name: "Carte 3")]
        ),
        MockMode(
            name: "Mode 2",
            summary: "Description de démonstration du mode 2.",
            maps: [MockMap(name: "Carte 4"), MockMap(name: "Carte 5")]
        ),
        MockMode(
            name: "Mode 3",
            summary: "Description de démonstration du mode 3.",
            maps: [MockMap(name: "Carte 6")]
        ),
    ]

    static let updates: [MockUpdate] = [
        MockUpdate(
            title: "Mise à jour exemple 1",
            date: "01 janvier 2026",
            summary: "Résumé de démonstration de la première mise à jour.",
            details: ["Premier point de démonstration", "Deuxième point de démonstration", "Troisième point de démonstration"]
        ),
        MockUpdate(
            title: "Mise à jour exemple 2",
            date: "15 janvier 2026",
            summary: "Résumé de démonstration de la deuxième mise à jour.",
            details: ["Point de démonstration A", "Point de démonstration B"]
        ),
        MockUpdate(
            title: "Mise à jour exemple 3",
            date: "01 février 2026",
            summary: "Résumé de démonstration de la troisième mise à jour.",
            details: ["Point de démonstration unique"]
        ),
    ]
}