import SwiftUI

struct GameModesView: View {
    @State private var search = ""

    var filtered: [MockMode] {
        search.isEmpty ? MockData.modes
            : MockData.modes.filter { $0.name.localizedCaseInsensitiveContains(search) }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.07, green: 0.07, blue: 0.12).ignoresSafeArea()
                List {
                    ForEach(filtered) { mode in
                        Section {
                            Text(mode.summary)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                            ForEach(mode.maps) { map in
                                NavigationLink(destination: MapDetailView(map: map, mode: mode)) {
                                    MapRow(map: map)
                                }
                                .hapticTap()
                            }
                        } header: {
                            HStack(spacing: 8) {
                                Image(systemName: mode.icon)
                                    .foregroundStyle(.yellow)
                                Text(mode.name)
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Modes")
            .searchable(text: $search, prompt: "Chercher un mode")
        }
    }
}

struct MapRow: View {
    let map: MockMap

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 10)
                .fill(LinearGradient(
                    colors: [.purple.opacity(0.6), .blue.opacity(0.6)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                ))
                .frame(width: 72, height: 48)
                .overlay(
                    Image(systemName: "map.fill")
                        .foregroundStyle(.white.opacity(0.6))
                )
            VStack(alignment: .leading, spacing: 2) {
                Text(map.name)
                    .font(.subheadline.bold())
                Text("Carte de démonstration")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct MapDetailView: View {
    let map: MockMap
    let mode: MockMode

    var body: some View {
        ZStack {
            Color(red: 0.07, green: 0.07, blue: 0.12).ignoresSafeArea()
            VStack(spacing: 24) {
                RoundedRectangle(cornerRadius: 20)
                    .fill(LinearGradient(
                        colors: [.purple.opacity(0.5), .blue.opacity(0.5)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ))
                    .frame(height: 220)
                    .overlay(
                        VStack(spacing: 8) {
                            Image(systemName: "map.fill")
                                .font(.system(size: 48))
                                .foregroundStyle(.white.opacity(0.5))
                            Text("Image de la carte\nbientôt disponible")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.5))
                                .multilineTextAlignment(.center)
                        }
                    )
                    .padding(.horizontal)

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: mode.icon)
                            .foregroundStyle(.yellow)
                        Text(mode.name)
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                    Text(map.name)
                        .font(.title2.bold())
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

                Spacer()
            }
            .padding(.top)
        }
        .navigationTitle(map.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
