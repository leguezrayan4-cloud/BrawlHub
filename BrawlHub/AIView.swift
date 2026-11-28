import SwiftUI

struct Conversation: Identifiable, Codable {
    var id = UUID()
    var name: String
    var messages: [ChatItem]
    var lastUpdated: Date = Date()
}

struct ChatItem: Identifiable, Codable {
    let id: UUID
    let role: String
    let text: String
    init(role: String, text: String) {
        self.id = UUID()
        self.role = role
        self.text = text
    }
}

@MainActor
final class ConversationStore: ObservableObject {
    @Published var conversations: [Conversation] = []

    private let key = "aiConversations"

    init() { load() }

    func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([Conversation].self, from: data)
        else { return }
        conversations = decoded
    }

    func save() {
        if let data = try? JSONEncoder().encode(conversations) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    func newConversation() -> Conversation {
        let conv = Conversation(name: "Nouvelle conversation", messages: [])
        conversations.insert(conv, at: 0)
        save()
        return conv
    }

    func update(_ conv: Conversation) {
        if let i = conversations.firstIndex(where: { $0.id == conv.id }) {
            conversations[i] = conv
            save()
        }
    }

    func delete(_ conv: Conversation) {
        conversations.removeAll { $0.id == conv.id }
        save()
    }

    func rename(_ conv: Conversation, to name: String) {
        if let i = conversations.firstIndex(where: { $0.id == conv.id }) {
            conversations[i].name = name
            save()
        }
    }
}

struct AIView: View {
    @StateObject private var store = ConversationStore()
    @State private var selectedConv: Conversation?
    @State private var showList = false

    var body: some View {
        NavigationStack {
            Group {
                if let conv = selectedConv {
                    ChatView(conversation: conv, store: store, onBack: {
                        selectedConv = nil
                    })
                } else {
                    conversationList
                }
            }
            .navigationTitle(selectedConv == nil ? "IA" : selectedConv!.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if selectedConv == nil {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            Haptics.impact(.medium)
                            selectedConv = store.newConversation()
                        } label: {
                            Image(systemName: "square.and.pencil")
                        }
                    }
                } else {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button { Haptics.tap(); selectedConv = nil } label: {
                            Image(systemName: "chevron.left")
                        }
                    }
                }
            }
        }
    }

    private var conversationList: some View {
        ZStack {
            Color(red: 0.07, green: 0.07, blue: 0.12).ignoresSafeArea()
            if store.conversations.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "bubble.left.and.bubble.right")
                        .font(.system(size: 48))
                        .foregroundStyle(.secondary)
                    Text("Aucune conversation")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    Button {
                        Haptics.impact(.medium)
                            selectedConv = store.newConversation()
                    } label: {
                        Text("Nouvelle conversation")
                            .font(.headline)
                            .padding()
                            .background(Color.yellow)
                            .foregroundStyle(.black)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
            } else {
                List {
                    ForEach(store.conversations) { conv in
                        Button { Haptics.tap(); selectedConv = conv } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(conv.name)
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                Text(conv.messages.last?.text ?? "Aucun message")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                Haptics.warning()
                                store.delete(conv)
                            } label: {
                                Label("Supprimer", systemImage: "trash")
                            }
                        }
                        .swipeActions(edge: .leading) {
                            Button {
                                rename(conv)
                            } label: {
                                Label("Renommer", systemImage: "pencil")
                            }
                            .tint(.orange)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
        }
    }

    private func rename(_ conv: Conversation) {
        // Renommage via alerte — géré dans ChatView toolbar
    }
}

struct ChatView: View {
    @State var conversation: Conversation
    @ObservedObject var store: ConversationStore
    let onBack: () -> Void

    @StateObject private var quota = QuotaStore()
    @State private var draft = ""
    @State private var sending = false
    @State private var errorText: String?
    @State private var sendTask: Task<Void, Never>?
    @State private var showRename = false
    @State private var newName = ""
    @FocusState private var inputFocused: Bool

    private let client = ServerClient()

    var body: some View {
        ZStack {
            Color(red: 0.07, green: 0.07, blue: 0.12).ignoresSafeArea()
            VStack(spacing: 0) {
                quotaBar
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 10) {
                            if conversation.messages.isEmpty {
                                Text("Pose une question sur les brawlers, leurs gadgets ou leurs star powers.")
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity)
                                    .padding(.top, 40)
                            }
                            ForEach(conversation.messages) { item in
                                bubble(item).id(item.id)
                            }
                            if sending {
                                HStack {
                                    ProgressView().tint(.yellow)
                                    Text("Génération en cours...")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.leading)
                            }
                            if let errorText {
                                Text(errorText)
                                    .font(.footnote)
                                    .foregroundStyle(.red)
                                    .padding(.horizontal)
                            }
                        }
                        .padding()
                    }
                    .scrollDismissesKeyboard(.interactively)
                    .onChange(of: conversation.messages.count) { _ in
                        if let last = conversation.messages.last {
                            withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                        }
                    }
                }
                inputBar
            }
        }
        .navigationTitle(conversation.name)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { Haptics.tap(); onBack() } label: {
                    Image(systemName: "chevron.left")
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button { Haptics.tap(); showRename = true } label: {
                        Label("Renommer", systemImage: "pencil")
                    }
                    Button(role: .destructive) {
                        Haptics.warning()
                        store.delete(conversation)
                        onBack()
                    } label: {
                        Label("Supprimer", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .alert("Renommer", isPresented: $showRename) {
            TextField("Nom de la conversation", text: $newName)
            Button("OK") {
                if !newName.isEmpty {
                    Haptics.success()
                    conversation.name = newName
                    store.rename(conversation, to: newName)
                }
            }
            Button("Annuler", role: .cancel) {}
        }
        .onAppear {
            quota.refreshMonth()
            newName = conversation.name
        }
        .dismissKeyboardOnTap()
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

            if sending {
                Button {
                    Haptics.warning()
                    sendTask?.cancel()
                    sending = false
                } label: {
                    Image(systemName: "stop.circle.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(.red)
                }
            } else {
                Button { send() } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 32))
                }
                .disabled(draft.trimmingCharacters(in: .whitespaces).isEmpty)
            }
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
            Haptics.error()
            errorText = "Quota mensuel atteint."
            return
        }
        Haptics.impact(.medium)
        errorText = nil
        draft = ""
        inputFocused = false
        conversation.messages.append(ChatItem(role: "user", text: text))
        store.update(conversation)
        sending = true
        let history = conversation.messages.map { ChatMsg(role: $0.role, content: $0.text) }

        sendTask = Task {
            do {
                let reply = try await client.chat(messages: history)
                if !Task.isCancelled {
                    conversation.messages.append(ChatItem(role: "assistant", text: reply))
                    Haptics.success()
                    // Auto-renomme la conv sur le premier message
                    if conversation.messages.count == 2 && conversation.name == "Nouvelle conversation" {
                        let shortName = String(text.prefix(30))
                        conversation.name = shortName
                        store.rename(conversation, to: shortName)
                    }
                    store.update(conversation)
                    quota.registerMessage()
                }
            } catch {
                if !Task.isCancelled {
                    Haptics.error()
                    errorText = (error as? LocalizedError)?.errorDescription ?? "Une erreur est survenue."
                }
            }
            sending = false
        }
    }
}
