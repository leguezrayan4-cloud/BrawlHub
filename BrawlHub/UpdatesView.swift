import SwiftUI

struct UpdatesView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("Maquette : les vraies mises à jour seront branchées plus tard.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section {
                    ForEach(MockData.updates) { update in
                        NavigationLink {
                            UpdateDetailView(update: update)
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(update.title)
                                    .font(.headline)
                                Text(update.date)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(update.summary)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .navigationTitle("Mises à jour")
        }
    }
}

struct UpdateDetailView: View {
    let update: MockUpdate

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(update.title)
                    .font(.title2.bold())
                Text(update.date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(update.summary)

                ForEach(update.details, id: \.self) { line in
                    HStack(alignment: .top, spacing: 8) {
                        Text("•")
                        Text(line)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle("Détail")
        .navigationBarTitleDisplayMode(.inline)
    }
}