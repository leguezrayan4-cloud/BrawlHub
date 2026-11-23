import SwiftUI

struct BrawlerDetailView: View {
    let brawler: Brawler

    var body: some View {
        ZStack {
            Color(red: 0.07, green: 0.07, blue: 0.12).ignoresSafeArea()
            ScrollView {
                VStack(spacing: 16) {
                    AsyncImage(url: URL(string: brawler.imageUrl ?? "")) { img in
                        img.resizable().scaledToFit()
                    } placeholder: { ProgressView() }
                    .frame(height: 180)

                    Text(brawler.displayName)
                        .font(.system(size: 32, weight: .black))

                    HStack(spacing: 8) {
                        if let r = brawler.rarity?.name { pill(r, color: brawler.rarityColor) }
                        if let c = brawler.brawlerClass?.name { pill(c, color: .gray) }
                    }

                    if let d = brawler.description, !d.isEmpty {
                        Text(d).multilineTextAlignment(.center).padding(.horizontal)
                    }

                    section("Gadgets", items: brawler.gadgets ?? [])
                    section("Star Powers", items: brawler.starPowers ?? [])
                }
                .padding()
            }
        }
        .navigationTitle(brawler.displayName)
        .navigationBarTitleDisplayMode(.inline)
    }

    func pill(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.caption.bold())
            .padding(.horizontal, 10).padding(.vertical, 5)
            .background(color.opacity(0.35))
            .clipShape(Capsule())
    }

    @ViewBuilder
    func section(_ title: String, items: [Brawler.Ability]) -> some View {
        if !items.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Text(title).font(.title3.bold())
                ForEach(items) { a in
                    HStack(alignment: .top, spacing: 10) {
                        AsyncImage(url: URL(string: a.imageUrl ?? "")) { img in
                            img.resizable().scaledToFit()
                        } placeholder: { Color.clear }
                        .frame(width: 44, height: 44)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(a.name).font(.subheadline.bold())
                            if let d = a.description {
                                Text(d).font(.footnote).foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }
}
