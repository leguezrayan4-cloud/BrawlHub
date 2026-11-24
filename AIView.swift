import SwiftUI

struct ChatItem: Identifiable {
    let id = UUID()
    let role: String
    let text: String
}

struct AIView: View {
    @StateObject private var quota = QuotaStore()
    @State private var messages: [ChatItem] = []
    @State private var draft = ""
    @State private var sending = false
    @State private var errorText: String?
    @FocusState private var inputFocused: Bool

    private let client = ServerClient()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                quotaBar
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 10) {
                            if messages.isEmpty {
                                Text("Pose une question sur les brawlers, leurs gadgets ou leurs star powers.")
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity)
                                    .padding(.top, 40)
                            }
                            ForEach(messages) { item in
                                bubble(item).id(item.id)
                            }
                            if sending {
                                ProgressView().tint(.yellow).padding(.leading)
                            }
                            if let errorText {
                                Text(errorText)
                                    .font(.footnote)
                                    .foregroundStyle(.red)
                            }
                        }
                        .padding()
                    }
                    .scrollDismissesKeyboard(.interactively)
                    .onChange(of: messages.count) { _, _ in
                        if let last = messages.last {
                            withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                        }
                    }
                }
                inputBar
            }
            .navigationTitle("IA")
            .dismissKeyboardOnTap()
            .onAppear { quota.refreshMonth() }
        }
    }

    private var quotaBar: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle().stroke(Color.white.opacity(0.15), lineWidth: 3)
                Circle()
                    .trim(from: 0, to: quota.fractionUsed)
                    .stroke(Color.yellow, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .rotationEffect(.degrees(-90))
            }
            .frame(width: 18, height: 18)
            Text("Messages ce mois-ci : \(quota.remaining) / \(QuotaStore.monthlyLimit)")
                .font(.footnote)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }

    private var inputBar: some View {
        HStack(alignment: .bottom, spacing: 8) {
            TextField("Écris un message", text: $draft, axis: .vertical)
                .lineLimit(1...5)
                .focused($inputFocused)
                .padding(10)
                .background(Color.white.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 18))

            Button { send() } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
            }
            .disabled(draft.trimmingCharacters(in: .whitespaces).isEmpty || sending)
            .accessibilityLabel("Envoyer")
        }
        .padding()
    }

    private func bubble(_ item: ChatItem) -> some View {
        HStack {
            if item.role == "user" { Spacer(minLength: 40) }
            Text(item.text)
                .padding(12)
                .background(item.role == "user" ? Color.yellow.opacity(0.25) : Color.white.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            if item.role != "user" { Spacer(minLength: 40) }
        }
    }

    private func send() {
        let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !sending else { return }
        guard quota.remaining > 0 else {
            errorText = "Quota mensuel atteint. Il se remet à zéro le mois prochain."
            return
        }
        errorText = nil
        draft = ""
        inputFocused = false
        messages.append(ChatItem(role: "user", text: text))
        sending = true
        let history = messages.map { ChatMsg(role: $0.role, content: $0.text) }

        Task {
            do {
                let reply = try await client.chat(messages: history)
                messages.append(ChatItem(role: "assistant", text: reply))
                quota.registerMessage()
            } catch {
                errorText = (error as? LocalizedError)?.errorDescription ?? "Une erreur est survenue."
            }
            sending = false
        }
    }
}
