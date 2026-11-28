import SwiftUI

struct OnboardingView: View {
    @AppStorage("onboardingDone") var onboardingDone = false
    @AppStorage("savedPlayerTag") var savedPlayerTag = ""
    @State private var page = 0
    @State private var tagInput = ""

    var body: some View {
        ZStack {
            Color(red: 0.07, green: 0.07, blue: 0.12).ignoresSafeArea()
            TabView(selection: $page) {
                // Page 1
                VStack(spacing: 24) {
                    Image(systemName: "gamecontroller.fill")
                        .font(.system(size: 72))
                        .foregroundStyle(.yellow)
                    Text("Bienvenue sur\nBrawlHub")
                        .font(.system(size: 34, weight: .black))
                        .multilineTextAlignment(.center)
                    Text("Ton compagnon ultime pour\nBrawl Stars.")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    Button { withAnimation { page = 1 } } label: {
                        Text("Continuer")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.yellow)
                            .foregroundStyle(.black)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }.padding(.horizontal, 40).padding(.top, 16)
                }
                .padding()
                .tag(0)

                // Page 2
                VStack(spacing: 24) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 72))
                        .foregroundStyle(.yellow)
                    Text("IA, Brawlers\n& Mises à jour")
                        .font(.system(size: 34, weight: .black))
                        .multilineTextAlignment(.center)
                    Text("Consulte les stats de tous les brawlers, suis les mises à jour et pose tes questions à l'IA.")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    Button { withAnimation { page = 2 } } label: {
                        Text("Continuer")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.yellow)
                            .foregroundStyle(.black)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }.padding(.horizontal, 40).padding(.top, 16)
                }
                .padding()
                .tag(1)

                // Page 3 — tag
                VStack(spacing: 24) {
                    Image(systemName: "person.crop.circle.badge.plus")
                        .font(.system(size: 72))
                        .foregroundStyle(.yellow)
                    Text("Ton tag\nBrawl Stars")
                        .font(.system(size: 34, weight: .black))
                        .multilineTextAlignment(.center)
                    Text("Lie ton compte pour accéder à tes stats personnelles.")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    TextField("#XXXXXXXX", text: $tagInput)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                        .padding()
                        .background(Color.white.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal, 40)
                    VStack(spacing: 12) {
                        Button {
                            savedPlayerTag = tagInput.uppercased().replacingOccurrences(of: "#", with: "")
                            Haptics.success()
                            onboardingDone = true
                        } label: {
                            Text("C'est parti !")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.yellow)
                                .foregroundStyle(.black)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .disabled(tagInput.trimmingCharacters(in: .whitespaces).isEmpty)
                        .padding(.horizontal, 40)

                        Button { Haptics.impact(.soft); onboardingDone = true } label: {
                            Text("Passer")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding()
                .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .onChange(of: page) { _ in Haptics.selection() }
        }
    }
}
