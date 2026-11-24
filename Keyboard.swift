import SwiftUI
import UIKit

extension View {
    // Ferme le clavier quand on touche en dehors d'un champ de saisie
    func dismissKeyboardOnTap() -> some View {
        onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}
