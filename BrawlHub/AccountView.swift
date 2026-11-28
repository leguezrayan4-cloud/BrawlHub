import SwiftUI

// Interface de création de compte. La connexion n'est pas encore branchée.
struct AccountView: View {
    enum Mode: String, CaseIterable {
        case create = "Créer un compte"
        case login = "Se connecter"
    }

    @State private var mode: Mode = .create
    @State private var pseudo = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirm = ""
    @State private var showInfo = false
    @FocusState private var focused: Bool

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Mode", selection: $mode) {
                        ForEach(Mode.allCases, id: \.self) { m in
                            Text(m.rawValue).tag(m)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: mode) { _ in Haptics.selection() }
                }

                Section {
                    if mode == .create {
                        TextField("Pseudo", text: $pseudo)
                            .focused($focused)
                    }
                    TextField("Adresse e-mail", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    SecureField("Mot de passe", text: $password)
                    if mode == .create {
                        SecureField("Confirmer le mot de passe", text: $confirm)
                    }
                } footer: {
                    if mode == .create {
                        Text("Ton compte te permettra de retrouver tes favoris et ton historique de chat sur plusieurs appareils.")
                    }
                }

                Section {
                    Button(mode == .create ? "Créer mon compte" : "Me connecter") {
                        Haptics.warning()
                        showInfo = true
                    }
                    .frame(maxWidth: .infinity)
                    .disabled(email.isEmpty || password.isEmpty)
                } footer: {
                    Text("Bientôt disponible : l'inscription n'est pas encore branchée.")
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Compte")
            .alert("Bientôt disponible", isPresented: $showInfo) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("La création de compte n'est pas encore branchée. L'interface est prête.")
            }
            .dismissKeyboardOnTap()
        }
    }
}
