import SwiftUI

struct UpdatesView: View {
    @State private var search = ""

    var filtered: [MockUpdate] {
        search.isEmpty ? MockData.updates
            : MockData.updates.filter {
                $0.title.localizedCaseInsensitiveContains(search) ||
                $0.version.localizedCaseInsensitiveContains(search)
            }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.07, green: 0.07, blue: 0.12).ignoresSafeArea()
                List {
                    ForEach(filtered) { update in
                        NavigationLink(destination: UpdateDetailView(update: update)) {
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text(update.title)
                                        .font(.headline)
                                    Spacer()
                                    Text("v\(update.version)")
                                        .font(.caption.bold())
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 3)
                                        .background(Color.yellow.opacity(0.2))
                                        .foregroundStyle(.yellow)
                                        .clipShape(Capsule())
                                }
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
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Mises à jour")
            .searchable(text: $search, prompt: "Chercher une mise à jour")
        }
    }
}

struct UpdateDetailView: View {
    let update: MockUpdate

    var body: some View {
        ZStack {
            Color(red: 0.07, green: 0.07, blue: 0.12).ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(update.title)
                                .font(.title2.bold())
                            Text(update.date)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text("v\(update.version)")
                            .font(.headline.bold())
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.yellow.opacity(0.2))
                            .foregroundStyle(.yellow)
                            .clipShape(Capsule())
                    }

                    Text(update.summary)
                        .font(.body)
                        .foregroundStyle(.secondary)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Nouveautés")
                            .font(.headline)
                        ForEach(update.details, id: \.self) { line in
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.yellow)
                                Text(line)
                                    .font(.subheadline)
                            }
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .navigationTitle("Détail")
        .navigationBarTitleDisplayMode(.inline)
    }
}
