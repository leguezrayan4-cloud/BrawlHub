import SwiftUI

struct GameModesView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("Maquette : les vraies données seront branchées plus tard.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                ForEach(MockData.modes) { mode in
                    Section {
                        Text(mode.summary)
                            .foregroundStyle(.secondary)
                        ForEach(mode.maps) { map in
                            MapRow(name: map.name)
                        }
                    } header: {
                        Text(mode.name)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .navigationTitle("Modes")
        }
    }
}

private struct MapRow: View {
    let name: String

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 10)
                .fill(
                    LinearGradient(
                        colors: [.purple.opacity(0.6), .blue.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 72, height: 48)
            Text(name)
        }
    }
}