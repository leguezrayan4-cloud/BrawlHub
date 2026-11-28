import SwiftUI
import UIKit

/// Vibrations de l'app. Chaque type correspond à un type d'action :
/// - tap()        : navigation légère (ouvrir une fiche, retour, boutons secondaires)
/// - impact(...)  : action principale (envoyer, chercher, nouvelle conversation)
/// - selection()  : changement de sélection (onglets, sélecteur, pages)
/// - success()    : action réussie (réponse reçue, tag enregistré)
/// - warning()    : action sensible (supprimer, arrêter)
/// - error()      : échec (erreur réseau, quota atteint)
enum Haptics {
    private static var enabled: Bool {
        UserDefaults.standard.object(forKey: "hapticsEnabled") as? Bool ?? true
    }

    private static func onMain(_ work: @escaping () -> Void) {
        guard enabled else { return }
        if Thread.isMainThread { work() } else { DispatchQueue.main.async(execute: work) }
    }

    static func tap() { impact(.light) }

    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        onMain {
            let g = UIImpactFeedbackGenerator(style: style)
            g.prepare()
            g.impactOccurred()
        }
    }

    static func selection() {
        onMain {
            let g = UISelectionFeedbackGenerator()
            g.prepare()
            g.selectionChanged()
        }
    }

    static func success() { notify(.success) }
    static func warning() { notify(.warning) }
    static func error() { notify(.error) }

    private static func notify(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        onMain {
            let g = UINotificationFeedbackGenerator()
            g.prepare()
            g.notificationOccurred(type)
        }
    }
}

extension View {
    /// Vibration au toucher, sans bloquer l'action du bouton ou du lien.
    func hapticTap(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .light) -> some View {
        simultaneousGesture(TapGesture().onEnded { Haptics.impact(style) })
    }
}
