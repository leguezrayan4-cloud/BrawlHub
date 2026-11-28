import SwiftUI

struct BrawlerListView: View {
    @StateObject private var store = BrawlerStore()
    @State private var search = ""

    private let columns = [GridItem(.adaptive(minimum: 105), spacing: 12)]

    var filtered: [Brawler] {
        search.isEmpty ? store.brawlers
            : store.brawlers.filter { $0.name.localizedCaseInsensitiveContains(search) }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.07, green: 0.07, blue: 0.12).ignoresSafeArea()
                if store.loading && store.brawlers.isEmpty {
                    ProgressView().tint(.yellow)
                } else if let error = store.error, store.brawlers.isEmpty {
                    VStack(spacing: 12) {
                        Text(error).multilineTextAlignment(.center)
                        Button("Réessayer") { Haptics.tap(); Task { await store.load() } }
                            .buttonStyle(.borderedProminent).tint(.yellow)
                    }.padding()
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(filtered) { b in
                                NavigationLink(value: b.id) { BrawlerCard(brawler: b) }
                                    .buttonStyle(.plain)
                                    .hapticTap()
                            }
                        }.padding()
                    }
                }
            }
            .navigationTitle("Brawlers")
            .searchable(text: $search, prompt: "Chercher un brawler")
            .navigationDestination(for: Int.self) { id in
                if let b = store.brawlers.first(where: { $0.id == id }) {
                    BrawlerDetailView(brawler: b)
                }
            }
            .task { if store.brawlers.isEmpty { await store.load() } }
            .refreshable {
                await store.load()
                Haptics.impact(.medium)
            }
        }
    }
}

struct BrawlerCard: View {
    let brawler: Brawler

    var body: some View {
        VStack(spacing: 6) {
            AsyncImage(url: URL(string: brawler.imageUrl ?? "")) { img in
                img.resizable().scaledToFit()
            } placeholder: {
                ProgressView()
            }
            .frame(height: 80)
            Text(brawler.displayName)
                .font(.system(size: 13, weight: .heavy))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(8)
        .frame(maxWidth: .infinity)
        .background(brawler.rarityColor.opacity(0.25))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(brawler.rarityColor, lineWidth: 2))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
